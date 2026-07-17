<?php
namespace App\Http\Controllers\Api\Member;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class ReferralController extends Controller
{
    public function index(Request $request)
    {
        $user    = $request->user();
        $referred = User::where('referred_by', $user->id)
            ->select('id', 'full_name', 'phone', 'kyc_status', 'created_at')
            ->latest()
            ->get()
            ->map(fn($u) => [
                'name'       => $u->full_name ?? $u->phone,
                'phone'      => $u->phone,
                'kyc_status' => $u->kyc_status,
                'joined_at'  => $u->created_at->diffForHumans(),
            ]);

        return response()->json([
            'success'         => true,
            'referral_code'   => $user->referral_code,
            'referrals_count' => $referred->count(),
            'referrals'       => $referred,
        ]);
    }
}
