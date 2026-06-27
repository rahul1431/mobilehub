<?php
namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class Msg91Service
{
    private string $apiKey;
    private string $senderId;
    private string $whatsappSource;
    private string $otpTemplateId;

    public function __construct()
    {
        $this->apiKey         = config('services.msg91.api_key');
        $this->senderId       = config('services.msg91.sender_id');
        $this->whatsappSource = config('services.msg91.whatsapp_source');
        $this->otpTemplateId  = config('services.msg91.otp_template_id');
    }

    public function sendOtp(string $phone, string $otp): bool
    {
        try {
            $mobile = ltrim($phone, '+');
            $response = Http::withHeaders(['authkey' => $this->apiKey])
                ->post('https://api.msg91.com/api/v5/otp', [
                    'template_id' => $this->otpTemplateId,
                    'mobile'      => $mobile,
                    'otp'         => $otp,
                    'sender'      => $this->senderId,
                ]);

            return $response->successful();
        } catch (\Exception $e) {
            Log::error('MSG91 OTP send failed: ' . $e->getMessage());
            return false;
        }
    }

    public function sendSms(string $phone, string $message): bool
    {
        try {
            $mobile = ltrim($phone, '+');
            $response = Http::withHeaders(['authkey' => $this->apiKey])
                ->post('https://api.msg91.com/api/v5/flow/', [
                    'sender'      => $this->senderId,
                    'mobiles'     => $mobile,
                    'message'     => $message,
                ]);

            return $response->successful();
        } catch (\Exception $e) {
            Log::error('MSG91 SMS failed: ' . $e->getMessage());
            return false;
        }
    }

    public function sendWhatsApp(string $phone, string $templateId, array $params = []): bool
    {
        try {
            $mobile = ltrim($phone, '+');
            $response = Http::withHeaders([
                'authkey'      => $this->apiKey,
                'content-type' => 'application/json',
            ])->post('https://api.msg91.com/api/v5/whatsapp/whatsapp-outbound-message/bulk/', [
                'integrated_number' => $this->whatsappSource,
                'content_type'      => 'template',
                'payload' => [
                    'messaging_product' => 'whatsapp',
                    'type'              => 'template',
                    'template'          => [
                        'name'     => $templateId,
                        'language' => ['code' => 'en'],
                        'components' => [
                            ['type' => 'body', 'parameters' => array_map(
                                fn($p) => ['type' => 'text', 'text' => $p], $params
                            )],
                        ],
                    ],
                    'to' => $mobile,
                ],
            ]);

            return $response->successful();
        } catch (\Exception $e) {
            Log::error('MSG91 WhatsApp failed: ' . $e->getMessage());
            return false;
        }
    }
}
