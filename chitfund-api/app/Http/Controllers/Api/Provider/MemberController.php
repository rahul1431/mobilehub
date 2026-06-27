<?php
namespace App\Http\Controllers\Api\Provider;

use App\Http\Controllers\Controller;
use App\Jobs\SendNotificationJob;
use App\Models\ChitGroup;
use App\Models\GroupMembership;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class MemberController extends Controller
{
    public function index(Request $request)
    {
        $members = User::where('provider_id', $request->user()->id)
            ->orWhereHas('memberships.group', fn($q) => $q->where('provider_id', $request->user()->id))
            ->with('kycDocuments')
            ->latest()
            ->paginate(30);

        return response()->json(['success' => true, 'data' => $members]);
    }

    public function show(User $member)
    {
        $member->load(['memberships.group', 'payments', 'kycDocuments']);
        return response()->json(['success' => true, 'data' => $member]);
    }

    public function store(Request $request, ChitGroup $group)
    {
        $this->authorize('update', $group);
        $request->validate(['phone' => 'required|string|min:10|max:15']);

        $currentCount = $group->memberships()->where('is_active', true)->count();
        if ($currentCount >= $group->total_members) {
            return response()->json(['success' => false, 'message' => 'Group is full.'], 422);
        }

        $member = User::firstOrCreate(
            ['phone' => $request->phone],
            [
                'role'          => 'chit_member',
                'provider_id'   => $request->user()->id,
                'kyc_status'    => 'pending',
                'referral_code' => strtoupper(Str::random(8)),
            ]
        );

        if ($group->memberships()->where('member_id', $member->id)->exists()) {
            return response()->json(['success' => false, 'message' => 'Member already in this group.'], 422);
        }

        $nextSlot = ($group->memberships()->max('membership_no') ?? 0) + 1;
        $membership = GroupMembership::create([
            'group_id'      => $group->id,
            'member_id'     => $member->id,
            'membership_no' => $nextSlot,
        ]);

        // Send invite SMS if new user
        SendNotificationJob::dispatch($member->id, 'group_invite', [
            'title' => 'You\'ve Been Added to a Chit Group',
            'body'  => "You've been added to {$group->name} chit group. Download Apna Saving app to manage your chit.",
            'sms'   => "Apna Saving: You've been added to {$group->name} chit. Monthly: ₹{$group->package->monthly_amount}. Download app: [link]",
        ], ['sms']);

        return response()->json(['success' => true, 'data' => $membership->load('member')], 201);
    }

    public function destroy(ChitGroup $group, User $member)
    {
        $this->authorize('update', $group);
        GroupMembership::where('group_id', $group->id)->where('member_id', $member->id)->update(['is_active' => false]);
        return response()->json(['success' => true, 'message' => 'Member removed from group.']);
    }
}
