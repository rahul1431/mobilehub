<?php
namespace App\Jobs;

use App\Models\Cycle;
use App\Models\GroupMembership;
use App\Models\Payment;
use App\Services\RazorpayService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class AutoDebitJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 60;

    public function __construct(private int $cycleId) {}

    public function handle(RazorpayService $razorpay): void
    {
        $cycle = Cycle::with('group.memberships.member')->findOrFail($this->cycleId);

        if (!in_array($cycle->status, ['open', 'auction'])) {
            return;
        }

        foreach ($cycle->group->memberships->where('is_active', true) as $membership) {
            $member  = $membership->member;
            $payment = Payment::where('cycle_id', $cycle->id)
                ->where('member_id', $member->id)
                ->where('status', 'pending')
                ->first();

            if (!$payment || !$membership->mandate_id) {
                continue;
            }

            try {
                $result = $razorpay->chargeMandateDebit(
                    $membership->mandate_id,
                    (int) ($payment->amount * 100), // paise
                    "Chit #{$cycle->group->name} – Cycle {$cycle->cycle_number}"
                );

                if ($result) {
                    $payment->update([
                        'razorpay_order_id' => $result['id'] ?? null,
                        'status'            => 'processing',
                        'payment_method'    => 'mandate',
                    ]);

                    SendNotificationJob::dispatch($member->id, 'auto_debit_initiated', [
                        'title' => 'Auto-debit Initiated',
                        'body'  => "₹{$payment->amount} will be debited for {$cycle->group->name} Cycle #{$cycle->cycle_number}.",
                        'sms'   => "Apna Saving: Auto-debit of ₹{$payment->amount} initiated for {$cycle->group->name}. Contact your provider if you have questions.",
                    ], ['push', 'sms']);
                }
            } catch (\Throwable $e) {
                Log::error("AutoDebit failed for payment {$payment->id}: " . $e->getMessage());
            }
        }
    }
}
