<?php
use App\Models\ChitGroup;
use App\Models\GroupMembership;
use Illuminate\Support\Facades\Broadcast;

/*
 * Public channel — anyone connected can receive bid updates for a live auction.
 * No authentication required; bid amounts are not sensitive, only who wins is.
 */
Broadcast::channel('cycle.{cycleId}', function ($user, $cycleId) {
    // Ensure the requester belongs to this cycle's group or is the provider
    if (!$user) return false;

    $membership = GroupMembership::whereHas('group', function ($q) use ($cycleId) {
        $q->whereHas('cycles', fn($c) => $c->where('id', $cycleId));
    })->where('member_id', $user->id)->where('is_active', true)->exists();

    $isProvider = ChitGroup::whereHas('cycles', fn($q) => $q->where('id', $cycleId))
        ->where('provider_id', $user->id)->exists();

    return $membership || $isProvider || $user->isSuperAdmin();
});
