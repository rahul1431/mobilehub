<?php
namespace App\Services;

use App\Models\Payment;
use Illuminate\Support\Facades\Log;
use Razorpay\Api\Api;

class RazorpayService
{
    private Api $razorpay;

    public function __construct()
    {
        $this->razorpay = new Api(
            config('services.razorpay.key_id'),
            config('services.razorpay.key_secret')
        );
    }

    public function createOrder(float $amount, string $receipt, array $notes = []): array
    {
        $order = $this->razorpay->order->create([
            'amount'   => (int) ($amount * 100), // paise
            'currency' => 'INR',
            'receipt'  => $receipt,
            'notes'    => $notes,
        ]);

        return [
            'order_id' => $order->id,
            'amount'   => $order->amount,
            'currency' => $order->currency,
            'key_id'   => config('services.razorpay.key_id'),
        ];
    }

    public function verifyPaymentSignature(string $orderId, string $paymentId, string $signature): bool
    {
        try {
            $this->razorpay->utility->verifyPaymentSignature([
                'razorpay_order_id'   => $orderId,
                'razorpay_payment_id' => $paymentId,
                'razorpay_signature'  => $signature,
            ]);
            return true;
        } catch (\Exception $e) {
            Log::error('Razorpay signature verification failed: ' . $e->getMessage());
            return false;
        }
    }

    public function verifyWebhookSignature(string $payload, string $signature): bool
    {
        try {
            $this->razorpay->utility->verifyWebhookSignature(
                $payload,
                $signature,
                config('services.razorpay.webhook_secret')
            );
            return true;
        } catch (\Exception $e) {
            Log::error('Razorpay webhook verification failed: ' . $e->getMessage());
            return false;
        }
    }

    public function chargeMandateDebit(string $mandateId, float $amount, string $receipt): ?string
    {
        try {
            $payment = $this->razorpay->subscription->createAddonPayment($mandateId, [
                'amount'   => (int) ($amount * 100),
                'currency' => 'INR',
                'receipt'  => $receipt,
            ]);
            return $payment->id;
        } catch (\Exception $e) {
            Log::error("Mandate debit failed for {$mandateId}: " . $e->getMessage());
            return null;
        }
    }
}
