<?php
return [

    /*
    |--------------------------------------------------------------------------
    | Razorpay
    |--------------------------------------------------------------------------
    */
    'razorpay' => [
        'key_id'     => env('RAZORPAY_KEY_ID'),
        'key_secret' => env('RAZORPAY_KEY_SECRET'),
    ],

    /*
    |--------------------------------------------------------------------------
    | MSG91 — OTP, SMS, WhatsApp
    |--------------------------------------------------------------------------
    */
    'msg91' => [
        'api_key'            => env('MSG91_API_KEY'),
        'sender_id'          => env('MSG91_SENDER_ID', 'APNSAV'),
        'otp_template_id'    => env('MSG91_OTP_TEMPLATE_ID'),
        'whatsapp_source'    => env('MSG91_WHATSAPP_SOURCE'),
        'whatsapp_namespace' => env('MSG91_WHATSAPP_NAMESPACE'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Firebase / FCM
    |--------------------------------------------------------------------------
    */
    'firebase' => [
        'project_id'       => env('FCM_PROJECT_ID'),
        'credentials_path' => env('FIREBASE_CREDENTIALS_PATH', storage_path('app/firebase-credentials.json')),
    ],

    /*
    |--------------------------------------------------------------------------
    | Digio — Aadhaar eKYC, PAN Verify, e-Sign
    |--------------------------------------------------------------------------
    */
    'digio' => [
        'api_key'    => env('DIGIO_API_KEY'),
        'api_secret' => env('DIGIO_API_SECRET'),
        'base_url'   => env('DIGIO_BASE_URL', 'https://api.digio.in'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Pusher — Real-time Auction Broadcasting
    |--------------------------------------------------------------------------
    */
    'pusher' => [
        'app_id'   => env('PUSHER_APP_ID'),
        'key'      => env('PUSHER_APP_KEY'),
        'secret'   => env('PUSHER_APP_SECRET'),
        'cluster'  => env('PUSHER_APP_CLUSTER', 'ap2'),
        'options'  => [
            'cluster'   => env('PUSHER_APP_CLUSTER', 'ap2'),
            'useTLS'    => true,
        ],
    ],

];
