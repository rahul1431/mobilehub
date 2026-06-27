<?php
namespace App\Http\Controllers\Api\Member;

use App\Http\Controllers\Controller;
use App\Models\Bid;
use App\Models\Cycle;
use App\Models\GroupMembership;
use Illuminate\Http\Request;

class BidController extends Controller
{
    public function index(Cycle $cycle)
    {
        $bids = Bid::where('cycle_id', $cycle->id)->with('member')->orderBy('bid_amount')->get();
        return response()->json(['success' => true, 'data' => $bids]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'cycle_id'   => 'required|exists:cycles,id',
            'bid_amount' => 'required|numeric|min:1',
        ]);

        $cycle = Cycle::findOrFail($data['cycle_id']);
        $userId = $request->user()->id;

        if ($cycle->status !== 'auction') {
            return response()->json(['success' => false, 'message' => 'This cycle is not open for bidding.'], 422);
        }

        $membership = GroupMembership::where('group_id', $cycle->group_id)
            ->where('member_id', $userId)
            ->where('has_won', false)
            ->first();

        if (!$membership) {
            return response()->json(['success' => false, 'message' => 'You are not eligible to bid.'], 403);
        }

        // Minimum bid: 70% of pot (cannot bid too low)
        $minBid = $cycle->total_pot * 0.70;
        if ($data['bid_amount'] < $minBid) {
            return response()->json(['success' => false, 'message' => "Minimum bid is ₹{$minBid}."], 422);
        }

        $bid = Bid::updateOrCreate(
            ['cycle_id' => $cycle->id, 'member_id' => $userId],
            ['bid_amount' => $data['bid_amount']]
        );

        // Broadcast via Pusher for real-time updates
        broadcast(new \App\Events\NewBidPlaced($bid))->toOthers();

        return response()->json(['success' => true, 'data' => $bid]);
    }
}
