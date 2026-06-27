<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('phone', 15)->unique();
            $table->string('full_name')->nullable();
            $table->string('email')->nullable()->unique();
            $table->enum('role', ['super_admin', 'chit_provider', 'chit_member'])->default('chit_member');
            $table->unsignedBigInteger('provider_id')->nullable(); // owning provider for members
            $table->enum('kyc_status', ['pending', 'verified', 'rejected'])->default('pending');
            $table->string('fcm_token')->nullable();
            $table->string('preferred_lang', 5)->default('en');
            $table->string('referral_code', 10)->unique()->nullable();
            $table->unsignedBigInteger('referred_by')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('provider_id')->references('id')->on('users')->nullOnDelete();
            $table->foreign('referred_by')->references('id')->on('users')->nullOnDelete();
        });
    }

    public function down(): void { Schema::dropIfExists('users'); }
};
