<?php
namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\Log;

class FcmService
{
    private $messaging;

    public function __construct()
    {
        $credentialsPath = storage_path(config('firebase.credentials.file', 'app/firebase-credentials.json'));
        if (file_exists($credentialsPath)) {
            $factory = (new Factory)->withServiceAccount($credentialsPath);
            $this->messaging = $factory->createMessaging();
        }
    }

    public function sendToToken(string $fcmToken, string $title, string $body, array $data = []): bool
    {
        if (!$this->messaging) return false;

        try {
            $message = CloudMessage::withTarget('token', $fcmToken)
                ->withNotification(Notification::create($title, $body))
                ->withData($data);

            $this->messaging->send($message);
            return true;
        } catch (\Exception $e) {
            Log::error('FCM send failed: ' . $e->getMessage());
            return false;
        }
    }

    public function sendToMultiple(array $tokens, string $title, string $body, array $data = []): void
    {
        if (!$this->messaging || empty($tokens)) return;

        try {
            $message = CloudMessage::new()
                ->withNotification(Notification::create($title, $body))
                ->withData($data);

            $this->messaging->sendMulticast($message, $tokens);
        } catch (\Exception $e) {
            Log::error('FCM multicast failed: ' . $e->getMessage());
        }
    }
}
