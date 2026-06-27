<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ProviderController extends Controller
{
    public function index()
    {
        $providers = User::where('role', 'chit_provider')
            ->withCount(['providerGroups as active_groups' => fn($q) => $q->whereIn('status', ['forming', 'active'])])
            ->latest()->get();

        return response()->json(['success' => true, 'data' => $providers]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'phone'     => 'required|string|min:10|max:15',
            'full_name' => 'required|string|max:150',
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

        return response()->json(['success' => true, 'data' => $provider], 201);
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
