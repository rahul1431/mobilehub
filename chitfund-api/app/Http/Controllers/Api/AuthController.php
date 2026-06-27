<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OtpVerification;
use App\Models\User;
use App\Services\Msg91Service;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function __construct(private Msg91Service $msg91) {}

    // POST /api/auth/send-otp
    public function sendOtp(Request $request): JsonResponse
    {
        $request->validate(['phone' => 'required|string|min:10|max:15']);

        $phone = $request->phone;
        $otp   = (string) random_int(100000, 999999);

        OtpVerification::where('phone', $phone)->delete();

        OtpVerification::create([
            'phone'      => $phone,
            'otp_hash'   => Hash::make($otp),
            'expires_at' => now()->addMinutes(10),
        ]);

        $sent = $this->msg91->sendOtp($phone, $otp);

        if (!$sent) {
            return response()->json(['success' => false, 'message' => 'Failed to send OTP. Try again.'], 500);
        }

        return response()->json(['success' => true, 'message' => 'OTP sent to ' . $phone]);
    }

    // POST /api/auth/verify-otp
    public function verifyOtp(Request $request): JsonResponse
    {
        $request->validate([
            'phone' => 'required|string',
            'otp'   => 'required|string|size:6',
        ]);

        $record = OtpVerification::where('phone', $request->phone)
            ->where('used', false)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if (!$record || !Hash::check($request->otp, $record->otp_hash)) {
            return response()->json(['success' => false, 'message' => 'Invalid or expired OTP.'], 422);
        }

        $record->update(['used' => true]);

        $user = User::firstOrCreate(
            ['phone' => $request->phone],
            [
                'role'          => 'chit_member',
                'kyc_status'    => 'pending',
                'referral_code' => strtoupper(Str::random(8)),
                'preferred_lang'=> 'en',
            ]
        );

        // Revoke previous tokens
        $user->tokens()->delete();
        $token = $user->createToken('mobile-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data'    => [
                'token' => $token,
                'user'  => $this->formatUser($user),
            ],
        ]);
    }

    // GET /api/auth/me
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => $this->formatUser($request->user()),
        ]);
    }

    // POST /api/auth/logout
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['success' => true, 'message' => 'Logged out successfully']);
    }

    // PUT /api/auth/fcm-token
    public function updateFcmToken(Request $request): JsonResponse
    {
        $request->validate(['fcm_token' => 'required|string']);
        $request->user()->update(['fcm_token' => $request->fcm_token]);
        return response()->json(['success' => true]);
    }

    private function formatUser(User $user): array
    {
        return [
            'id'             => $user->id,
            'phone'          => $user->phone,
            'full_name'      => $user->full_name,
            'role'           => $user->role,
            'kyc_status'     => $user->kyc_status,
            'preferred_lang' => $user->preferred_lang,
            'referral_code'  => $user->referral_code,
        ];
    }
}
