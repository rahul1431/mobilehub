<?php
namespace App\Http\Controllers\Api\Provider;

use App\Http\Controllers\Controller;
use App\Jobs\SendNotificationJob;
use App\Models\Bid;
use App\Models\ChitGroup;
use App\Models\Cycle;
use App\Models\Dividend;
use App\Models\GroupMembership;
use App\Models\Payment;
use Illuminate\Http\Request;

class CycleController extends Controller
{
    public function index(Request $request)
    {
        $cycles = Cycle::whereHas('group', fn($q) => $q->where('provider_id', $request->user()->id))
            ->with(['group', 'winner'])
            ->latest()
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $cycles]);
    }

    public function show(Cycle $cycle)
    {
        $cycle->load(['group', 'winner', 'payments.member', 'bids.member']);
        return response()->json(['success' => true, 'data' => $cycle]);
    }

    // POST /api/provider/groups/{group}/start-cycle
    public function start(Request $request, ChitGroup $group)
    {
        $this->authorize('update', $group);

        $nextCycleNo = $group->current_cycle + 1;
        $package = $group->package;

        if ($nextCycleNo > $package->duration_months) {
            return response()->json(['success' => false, 'message' => 'All cycles completed.'], 422);
        }

        $cycle = Cycle::create([
            'group_id'     => $group->id,
            'cycle_number' => $nextCycleNo,
            'due_date'     => now()->addDays(7)->toDateString(),
            'total_pot'    => $package->monthly_amount * $group->total_members,
            'cycle_method' => $request->input('cycle_method', 'manual'),
            'status'       => 'open',
        ]);

        // Create pending payment for each active member
        $memberships = GroupMembership::where('group_id', $group->id)->where('is_active', true)->get();
        foreach ($memberships as $m) {
            Payment::create([
                'cycle_id'  => $cycle->id,
                'member_id' => $m->member_id,
                'group_id'  => $group->id,
                'amount'    => $package->monthly_amount,
                'status'    => 'pending',
            ]);

            SendNotificationJob::dispatch($m->member_id, 'cycle_started', [
                'title' => "Cycle #{$nextCycleNo} Started",
                'body'  => "Pay ₹{$package->monthly_amount} for {$group->name} by " . now()->addDays(7)->format('d M Y'),
                'sms'   => "Apna Saving: Cycle #{$nextCycleNo} started for {$group->name}. Pay ₹{$package->monthly_amount} by " . now()->addDays(7)->format('d M') . ".",
            ]);
        }

        $group->update(['current_cycle' => $nextCycleNo, 'status' => 'active']);

        return response()->json(['success' => true, 'message' => "Cycle #{$nextCycleNo} started.", 'data' => $cycle]);
    }

    // POST /api/provider/cycles/{cycle}/pick-winner
    public function pickWinner(Request $request, Cycle $cycle)
    {
        $this->authorize('update', $cycle->group);

        if ($cycle->status === 'closed') {
            return response()->json(['success' => false, 'message' => 'Cycle already closed.'], 422);
        }

        $request->validate(['method' => 'required|in:manual,lottery,auction', 'winner_id' => 'required_if:method,manual|integer']);

        $winnerId = null;
        $winningBid = null;

        if ($request->method === 'manual') {
            $winnerId = $request->winner_id;
        } elseif ($request->method === 'lottery') {
            $eligible = GroupMembership::where('group_id', $cycle->group_id)
                ->where('has_won', false)->where('is_active', true)->inRandomOrder()->first();
            $winnerId = $eligible?->member_id;
        } elseif ($request->method === 'auction') {
            $lowestBid = Bid::where('cycle_id', $cycle->id)->orderBy('bid_amount')->first();
            if (!$lowestBid) {
                return response()->json(['success' => false, 'message' => 'No bids placed yet.'], 422);
            }
            $winnerId   = $lowestBid->member_id;
            $winningBid = $lowestBid->bid_amount;
            Bid::where('cycle_id', $cycle->id)->update(['is_winning' => false]);
            $lowestBid->update(['is_winning' => true]);
        }

        if (!$winnerId) {
            return response()->json(['success' => false, 'message' => 'Could not determine winner.'], 422);
        }

        // Calculate dividend
        $pot = $cycle->total_pot;
        $commission = $pot * ($cycle->group->package->commission_pct / 100);
        $netPot = $winningBid ?? ($pot - $commission);
        $dividendPerMember = ($pot - $netPot - $commission) / max($cycle->group->total_members - 1, 1);

        $cycle->update([
            'winner_id'           => $winnerId,
            'winning_bid'         => $netPot,
            'dividend_per_member' => max($dividendPerMember, 0),
            'cycle_method'        => $request->method,
            'status'              => 'closed',
            'closed_at'           => now(),
        ]);

        GroupMembership::where('group_id', $cycle->group_id)->where('member_id', $winnerId)->update(['has_won' => true]);

        // Create dividend records for non-winners
        $memberships = GroupMembership::where('group_id', $cycle->group_id)->where('member_id', '!=', $winnerId)->where('is_active', true)->get();
        foreach ($memberships as $m) {
            if ($dividendPerMember > 0) {
                Dividend::create(['cycle_id' => $cycle->id, 'member_id' => $m->member_id, 'amount' => $dividendPerMember]);
            }
        }

        // Notify winner
        $winner = \App\Models\User::find($winnerId);
        SendNotificationJob::dispatch($winnerId, 'chit_won', [
            'title' => 'Congratulations! You Won!',
            'body'  => "You won the chit for {$cycle->group->name}! Amount: ₹{$netPot}. Your provider will transfer the amount.",
            'sms'   => "Apna Saving: Congrats! You won Cycle #{$cycle->cycle_number} of {$cycle->group->name}. Amount ₹{$netPot}.",
        ]);

        return response()->json(['success' => true, 'message' => 'Winner selected.', 'data' => $cycle->fresh()]);
    }
}
