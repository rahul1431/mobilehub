<?php
namespace App\Http\Controllers\Api\Member;

use App\Http\Controllers\Controller;
use App\Models\Cycle;
use App\Models\Dividend;
use App\Models\GroupMembership;
use App\Models\Payment;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $activeGroups = GroupMembership::where('member_id', $userId)
            ->where('is_active', true)
            ->with(['group.package', 'group' => fn($q) => $q->whereIn('status', ['forming', 'active'])])
            ->get()
            ->filter(fn($m) => $m->group !== null);

        $nextPayment = Payment::where('member_id', $userId)
            ->where('status', 'pending')
            ->with(['cycle', 'group'])
            ->orderBy('created_at')
            ->first();

        $totalPaid     = Payment::where('member_id', $userId)->where('status', 'paid')->sum('amount');
        $totalDividend = Dividend::where('member_id', $userId)->where('status', 'disbursed')->sum('amount');
        $wonChits      = GroupMembership::where('member_id', $userId)->where('has_won', true)->count();

        return response()->json([
            'success' => true,
            'data'    => [
                'active_groups'    => $activeGroups->count(),
                'won_chits'        => $wonChits,
                'total_invested'   => $totalPaid,
                'total_dividends'  => $totalDividend,
                'next_payment'     => $nextPayment ? [
                    'amount'    => $nextPayment->amount + $nextPayment->penalty_amount,
                    'due_date'  => $nextPayment->cycle->due_date,
                    'group'     => $nextPayment->group->name,
                ] : null,
            ],
        ]);
    }
}
