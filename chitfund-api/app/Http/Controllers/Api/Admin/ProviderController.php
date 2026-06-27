<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\GroupMembership;
use App\Models\ProviderSubscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ProviderController extends Controller
{
    public function index()
    {
        $providers = User::where('role', 'chit_provider')
            ->with(['subscription.plan'])
            ->withCount([
                'providerGroups as active_groups' => fn($q) => $q->whereIn('status', ['forming', 'active']),
            ])
            ->latest()
            ->get()
            ->map(fn($p) => [
                'id'                  => $p->id,
                'phone'               => $p->phone,
                'full_name'           => $p->full_name,
                'kyc_status'          => $p->kyc_status,
                'active_groups'       => $p->active_groups,
                'total_members'       => GroupMembership::whereHas('group', fn($q) => $q->where('provider_id', $p->id))->where('is_active', true)->count(),
                'subscription_plan'   => $p->subscription?->plan?->name,
                'subscription_status' => $p->subscription?->status,
                'subscription_expiry' => $p->subscription?->expires_at,
                'created_at'          => $p->created_at,
            ]);

        return response()->json(['success' => true, 'data' => $providers]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'phone'     => 'required|string|min:10|max:15',
            'full_name' => 'nullable|string|max:150',
            'plan_id'   => 'nullable|exists:subscription_plans,id',
        ]);

        $provider = User::updateOrCreate(
            ['phone' => $request->phone],
            [
                'full_name'      => $request->full_name,
                'role'           => 'chit_provider',
                'kyc_status'     => 'pending',
                'referral_code'  => strtoupper(Str::random(8)),
                'preferred_lang' => 'en',
            ]
        );

        if ($request->plan_id) {
            ProviderSubscription::updateOrCreate(
                ['user_id' => $provider->id],
                [
                    'plan_id'    => $request->plan_id,
                    'status'     => 'active',
                    'starts_at'  => now(),
                    'expires_at' => now()->addYear(),
                ]
            );
        }

        return response()->json(['success' => true, 'data' => $provider->load('subscription.plan')], 201);
    }

    public function show(User $provider)
    {
        abort_if($provider->role !== 'chit_provider', 404);
        $provider->load(['providerGroups.package', 'subscription.plan']);
        return response()->json(['success' => true, 'data' => $provider]);
    }

    public function destroy(User $provider)
    {
        abort_if($provider->role !== 'chit_provider', 404);
        if ($provider->providerGroups()->whereIn('status', ['forming', 'active'])->exists()) {
            return response()->json(['success' => false, 'message' => 'Provider has active groups.'], 422);
        }
        $provider->update(['role' => 'chit_member']);
        return response()->json(['success' => true, 'message' => 'Provider demoted to member.']);
    }
}
