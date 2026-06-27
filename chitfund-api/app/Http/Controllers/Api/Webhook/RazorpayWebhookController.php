<?php
namespace App\Http\Controllers\Api\Webhook;

use App\Http\Controllers\Controller;
use App\Jobs\SendNotificationJob;
use App\Models\Payment;
use App\Services\RazorpayService;
use Illuminate\Http\Request;

class RazorpayWebhookController extends Controller
{
    public function handle(Request $request, RazorpayService $razorpay)
    {
        $payload   = $request->getContent();
        $signature = $request->header('X-Razorpay-Signature', '');

        if (!$razorpay->verifyWebhookSignature($payload, $signature)) {
            return response()->json(['error' => 'Invalid signature'], 400);
        }

        $event = $request->input('event');
        $data  = $request->input('payload.payment.entity', []);

        if ($event === 'payment.captured') {
            $orderId   = $data['order_id'] ?? null;
            $paymentId = $data['id'] ?? null;

            $payment = Payment::where('razorpay_order_id', $orderId)->first();
            if ($payment && $payment->status === 'pending') {
                $payment->update([
                    'razorpay_payment_id' => $paymentId,
                    'status'              => 'paid',
                    'paid_at'             => now(),
                ]);

                SendNotificationJob::dispatch($payment->member_id, 'payment_success', [
                    'title'             => 'Payment Received',
                    'body'              => "₹{$payment->amount} paid for {$payment->group->name}. Thank you!",
                    'sms'               => "Apna Saving: ₹{$payment->amount} received for {$payment->group->name}. Ref: {$paymentId}",
                    'whatsapp_template' => 'payment_receipt',
                    'whatsapp_params'   => [$payment->member->full_name ?? 'Member', $payment->group->name, "₹{$payment->amount}", $paymentId],
                ]);
            }
        }

        if ($event === 'payment.failed') {
            $orderId = $data['order_id'] ?? null;
            Payment::where('razorpay_order_id', $orderId)->update(['status' => 'failed']);
        }

        return response()->json(['status' => 'ok']);
    }
}
