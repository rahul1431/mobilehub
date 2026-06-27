<?php
namespace App\Console;

use App\Jobs\SendNotificationJob;
use App\Models\Cycle;
use App\Models\Payment;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule $schedule): void
    {
        // Daily at 9 AM: send payment reminders for cycles due in 3 days
        $schedule->call(function () {
            $dueSoon = Cycle::where('status', 'open')
                ->whereDate('due_date', now()->addDays(3)->toDateString())
                ->with('group.memberships.member')
                ->get();

            foreach ($dueSoon as $cycle) {
                foreach ($cycle->group->memberships->where('is_active', true) as $membership) {
                    $member = $membership->member;
                    $payment = Payment::where('cycle_id', $cycle->id)
                        ->where('member_id', $member->id)
                        ->where('status', 'pending')
                        ->first();

                    if ($payment) {
                        SendNotificationJob::dispatch($member->id, 'payment_reminder', [
                            'title'              => 'Payment Due in 3 Days',
                            'body'               => "Your chit payment of ₹{$cycle->group->package->monthly_amount} for {$cycle->group->name} is due on {$cycle->due_date->format('d M Y')}.",
                            'sms'                => "Apna Saving: Your chit payment ₹{$cycle->group->package->monthly_amount} for {$cycle->group->name} due on {$cycle->due_date->format('d M')}. Pay now via app.",
                            'whatsapp_template'  => 'payment_reminder',
                            'whatsapp_params'    => [$member->full_name ?? 'Member', $cycle->group->name, "₹{$cycle->group->package->monthly_amount}", $cycle->due_date->format('d M Y')],
                        ]);
                    }
                }
            }
        })->dailyAt('09:00')->name('payment-reminders');

        // Daily at 10 AM: apply penalties on overdue payments
        $schedule->call(function () {
            $overdue = Payment::where('status', 'pending')
                ->whereHas('cycle', fn($q) => $q->where('due_date', '<', now()->toDateString()))
                ->with('cycle.group.provider.penaltyRule')
                ->get();

            foreach ($overdue as $payment) {
                $rule = $payment->cycle->group->provider->penaltyRule;
                if ($rule && $payment->penalty_amount == 0) {
                    $daysLate = now()->diffInDays($payment->cycle->due_date);
                    if ($daysLate > $rule->grace_days) {
                        $penalty = $rule->flat_penalty + ($payment->amount * $rule->pct_penalty / 100);
                        $payment->update(['penalty_amount' => $penalty]);
                    }
                }
            }
        })->dailyAt('10:00')->name('apply-penalties');

        // Clear expired OTPs hourly
        $schedule->call(function () {
            \App\Models\OtpVerification::where('expires_at', '<', now())->delete();
        })->hourly()->name('clear-expired-otps');
    }

    protected function commands(): void
    {
        $this->load(__DIR__ . '/Commands');
        require base_path('routes/console.php');
    }
}
