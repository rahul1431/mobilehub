<?php
namespace App\Http\Controllers\Api\Member;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use App\Services\DigioService;
use Illuminate\Http\Request;

class KycController extends Controller
{
    public function status(Request $request)
    {
        $userId = $request->user()->id;
        $docs   = KycDocument::where('member_id', $userId)->get();

        return response()->json([
            'success'    => true,
            'kyc_status' => $request->user()->kyc_status,
            'documents'  => $docs,
        ]);
    }

    public function startAadhaar(Request $request, DigioService $digio)
    {
        $user   = $request->user();
        $result = $digio->initiateAadhaarKyc($user->phone, $user->full_name ?? $user->phone, $user->id);

        if (!$result) {
            return response()->json([
                'success' => false,
                'message' => 'Could not initiate KYC. Please try again.',
            ], 503);
        }

        KycDocument::updateOrCreate(
            ['member_id' => $user->id, 'doc_type' => 'aadhaar'],
            ['digio_request_id' => $result['id'] ?? null, 'verified' => false]
        );

        return response()->json([
            'success'      => true,
            'kyc_url'      => $result['url'] ?? null,
            'digio_id'     => $result['id'] ?? null,
            'redirect_url' => url('/api/member/kyc/callback'),
        ]);
    }

    public function verifyPan(Request $request, DigioService $digio)
    {
        $request->validate(['pan' => 'required|string|size:10|regex:/^[A-Z]{5}[0-9]{4}[A-Z]$/']);

        $user   = $request->user();
        $result = $digio->verifyPan(strtoupper($request->pan));

        if (!$result) {
            return response()->json(['success' => false, 'message' => 'PAN verification failed.'], 422);
        }

        KycDocument::updateOrCreate(
            ['member_id' => $user->id, 'doc_type' => 'pan'],
            ['verified' => true, 'storage_path' => $request->pan]
        );

        // Check if both aadhaar + PAN are done
        $bothDone = KycDocument::where('member_id', $user->id)
            ->whereIn('doc_type', ['aadhaar', 'pan'])
            ->where('verified', true)
            ->count() >= 2;

        if ($bothDone) {
            $user->update(['kyc_status' => 'verified']);
        }

        return response()->json(['success' => true, 'data' => $result]);
    }

    public function callback(Request $request)
    {
        return response('<html><body><script>window.close();</script>KYC complete. You may close this window.</body></html>', 200)
            ->header('Content-Type', 'text/html');
    }
}
