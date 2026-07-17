<?php
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\Admin\PackageController;
use App\Http\Controllers\Api\Admin\ProviderController;
use App\Http\Controllers\Api\Admin\AnalyticsController;
use App\Http\Controllers\Api\Provider\GroupController;
use App\Http\Controllers\Api\Provider\MemberController;
use App\Http\Controllers\Api\Provider\CycleController;
use App\Http\Controllers\Api\Provider\CollectionController;
use App\Http\Controllers\Api\Member\DashboardController;
use App\Http\Controllers\Api\Member\PassbookController;
use App\Http\Controllers\Api\Member\BidController;
use App\Http\Controllers\Api\Member\PaymentController;
use App\Http\Controllers\Api\Member\KycController;
use App\Http\Controllers\Api\Member\ReferralController;
use App\Http\Controllers\Api\Webhook\RazorpayWebhookController;
use App\Http\Controllers\Api\Webhook\DigioWebhookController;
use Illuminate\Support\Facades\Route;

// ─── Auth (Public) ───────────────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/send-otp',    [AuthController::class, 'sendOtp']);
    Route::post('/verify-otp',  [AuthController::class, 'verifyOtp']);
});

// ─── Webhooks (Public — must verify HMAC inside controller) ──────────────────
Route::prefix('webhook')->group(function () {
    Route::post('/razorpay', [RazorpayWebhookController::class, 'handle']);
    Route::post('/digio',    [DigioWebhookController::class, 'handle']);
});

// ─── Protected Routes ─────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    Route::get('/auth/me',              [AuthController::class, 'me']);
    Route::post('/auth/logout',         [AuthController::class, 'logout']);
    Route::put('/auth/fcm-token',       [AuthController::class, 'updateFcmToken']);
    Route::put('/auth/preferred-lang',  [AuthController::class, 'updatePreferredLang']);

    // ── Super Admin ──────────────────────────────────────────────────────────
    Route::middleware('role:super_admin')->prefix('admin')->group(function () {
        Route::apiResource('packages',  PackageController::class);
        Route::apiResource('providers', ProviderController::class);
        Route::get('/analytics',        [AnalyticsController::class, 'index']);
    });

    // ── Chit Provider ────────────────────────────────────────────────────────
    Route::middleware('role:chit_provider,super_admin')->prefix('provider')->group(function () {
        Route::apiResource('groups',  GroupController::class);
        Route::post('/groups/{group}/members',      [MemberController::class, 'store']);
        Route::delete('/groups/{group}/members/{member}', [MemberController::class, 'destroy']);
        Route::get('/members',                      [MemberController::class, 'index']);
        Route::get('/members/{member}',             [MemberController::class, 'show']);

        Route::post('/groups/{group}/start-cycle',  [CycleController::class, 'start']);
        Route::post('/cycles/{cycle}/pick-winner',  [CycleController::class, 'pickWinner']);
        Route::get('/cycles',                       [CycleController::class, 'index']);
        Route::get('/cycles/{cycle}',               [CycleController::class, 'show']);

        Route::get('/collections',                  [CollectionController::class, 'index']);
        Route::post('/payments/record',             [CollectionController::class, 'record']);
    });

    // ── Chit Member ──────────────────────────────────────────────────────────
    Route::middleware('role:chit_member')->prefix('member')->group(function () {
        Route::get('/dashboard',    [DashboardController::class, 'index']);
        Route::get('/passbook',     [PassbookController::class, 'index']);
        Route::get('/passbook/pdf', [PassbookController::class, 'exportPdf']);

        Route::get('/groups',                    [GroupController::class, 'myGroups']);
        Route::get('/groups/{group}',            [GroupController::class, 'showMemberView']);

        Route::post('/bids',         [BidController::class, 'store']);
        Route::get('/cycles/{cycle}/bids', [BidController::class, 'index']);

        Route::get('/payments',      [PaymentController::class, 'index']);
        Route::post('/payments/create-order', [PaymentController::class, 'createOrder']);
        Route::post('/payments/confirm',      [PaymentController::class, 'confirm']);

        Route::get('/kyc/status',         [KycController::class, 'status']);
        Route::post('/kyc/start-aadhaar', [KycController::class, 'startAadhaar']);
        Route::post('/kyc/verify-pan',    [KycController::class, 'verifyPan']);

        Route::get('/referrals',          [ReferralController::class, 'index']);
    });
});

// KYC redirect-back (no auth — Digio redirects the user's browser here)
Route::get('/member/kyc/callback', [KycController::class, 'callback']);
