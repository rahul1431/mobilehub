<?php
namespace App\Jobs;

use App\Models\NotificationLog;
use App\Models\User;
use App\Services\FcmService;
use App\Services\Msg91Service;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendNotificationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;

    public function __construct(
        private int    $userId,
        private string $messageType,
        private array  $payload,
        private array  $channels = ['push', 'sms', 'whatsapp']
    ) {}

    public function handle(FcmService $fcm, Msg91Service $msg91): void
    {
        $user = User::find($this->userId);
        if (!$user) return;

        $title   = $this->payload['title'] ?? 'Apna Saving';
        $body    = $this->payload['body']  ?? '';
        $sms     = $this->payload['sms']   ?? $body;
        $waTempl = $this->payload['whatsapp_template'] ?? null;
        $waParams= $this->payload['whatsapp_params']   ?? [];

        foreach ($this->channels as $channel) {
            $status = 'failed';

            if ($channel === 'push' && $user->fcm_token) {
                $ok = $fcm->sendToToken($user->fcm_token, $title, $body, ['type' => $this->messageType]);
                $status = $ok ? 'sent' : 'failed';
            }

            if ($channel === 'sms') {
                $ok = $msg91->sendSms($user->phone, $sms);
                $status = $ok ? 'sent' : 'failed';
            }

            if ($channel === 'whatsapp' && $waTempl) {
                $ok = $msg91->sendWhatsApp($user->phone, $waTempl, $waParams);
                $status = $ok ? 'sent' : 'failed';
            }

            NotificationLog::create([
                'user_id'      => $this->userId,
                'channel'      => $channel,
                'message_type' => $this->messageType,
                'payload'      => $this->payload,
                'status'       => $status,
            ]);
        }
    }
}
