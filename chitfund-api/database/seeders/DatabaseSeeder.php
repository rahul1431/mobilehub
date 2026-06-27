<?php
namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Subscription plans
        SubscriptionPlan::upsert([
            ['name' => 'Bronze', 'price' => 499,  'group_limit' => 5,   'member_limit' => 100, 'is_active' => true],
            ['name' => 'Silver', 'price' => 999,  'group_limit' => 15,  'member_limit' => 500, 'is_active' => true],
            ['name' => 'Gold',   'price' => 2499, 'group_limit' => -1,  'member_limit' => -1,  'is_active' => true],
        ], ['name'], ['price', 'group_limit', 'member_limit', 'is_active']);

        // Super admin (update phone to actual admin number)
        User::updateOrCreate(
            ['phone' => '+919999999999'],
            [
                'full_name'     => 'Admin',
                'role'          => 'super_admin',
                'kyc_status'    => 'verified',
                'referral_code' => 'ADMIN001',
                'preferred_lang'=> 'en',
            ]
        );
    }
}
