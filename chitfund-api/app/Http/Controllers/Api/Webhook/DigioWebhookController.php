<?php
namespace App\Http\Controllers\Api\Webhook;

use App\Http\Controllers\Controller;
use App\Models\KycDocument;
use App\Models\User;
use Illuminate\Http\Request;

class DigioWebhookController extends Controller
{
    public function handle(Request $request)
    {
        $event = $request->input('event');
        $data  = $request->input('data', []);

        if ($event === 'kyc.completed') {
            $digioRequestId = $data['id'] ?? null;
            $doc = KycDocument::where('digio_request_id', $digioRequestId)->first();
            if ($doc) {
                $doc->update(['verified' => true, 'verified_at' => now()]);

                $allVerified = KycDocument::where('member_id', $doc->member_id)
                    ->whereIn('doc_type', ['aadhaar', 'pan'])
                    ->where('verified', true)
                    ->count() >= 2;

                if ($allVerified) {
                    User::where('id', $doc->member_id)->update(['kyc_status' => 'verified']);
                }
            }
        }

        if ($event === 'sign.completed') {
            $docId = $data['id'] ?? null;
            \App\Models\Agreement::where('digio_doc_id', $docId)->update(['signed_at' => now()]);
        }

        return response()->json(['status' => 'ok']);
    }
}
