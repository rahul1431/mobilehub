<?php
namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class DigioService
{
    private string $apiKey;
    private string $apiSecret;
    private string $baseUrl;

    public function __construct()
    {
        $this->apiKey    = config('services.digio.api_key');
        $this->apiSecret = config('services.digio.api_secret');
        $this->baseUrl   = config('services.digio.base_url', 'https://api.digio.in');
    }

    private function client()
    {
        return Http::withBasicAuth($this->apiKey, $this->apiSecret)
            ->baseUrl($this->baseUrl);
    }

    public function initiateAadhaarKyc(string $phone, string $name, int $userId): ?array
    {
        try {
            $response = $this->client()->post('/v2/client/kyc/initiate', [
                'customer_identifier' => $phone,
                'customer_name'       => $name,
                'reference_id'        => 'kyc_' . $userId,
                'notify_customer'     => false,
            ]);

            if ($response->successful()) {
                return $response->json();
            }
            return null;
        } catch (\Exception $e) {
            Log::error('Digio Aadhaar KYC initiation failed: ' . $e->getMessage());
            return null;
        }
    }

    public function verifyPan(string $panNumber): ?array
    {
        try {
            $response = $this->client()->post('/v2/client/kyc/pan/verify', [
                'pan' => strtoupper($panNumber),
            ]);

            return $response->successful() ? $response->json() : null;
        } catch (\Exception $e) {
            Log::error('Digio PAN verification failed: ' . $e->getMessage());
            return null;
        }
    }

    public function requestEsign(string $documentId, string $signerPhone, string $signerName): ?array
    {
        try {
            $response = $this->client()->post('/v2/client/document/request_sign', [
                'document_id' => $documentId,
                'signers'     => [
                    [
                        'identifier' => $signerPhone,
                        'name'       => $signerName,
                        'reason'     => 'Chit Fund Agreement',
                    ],
                ],
            ]);

            return $response->successful() ? $response->json() : null;
        } catch (\Exception $e) {
            Log::error('Digio e-sign request failed: ' . $e->getMessage());
            return null;
        }
    }
}
