<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('notifications_log', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('channel', ['push', 'sms', 'whatsapp']);
            $table->string('message_type');
            $table->json('payload')->nullable();
            $table->enum('status', ['sent', 'failed', 'pending'])->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('notifications_log'); }
};
