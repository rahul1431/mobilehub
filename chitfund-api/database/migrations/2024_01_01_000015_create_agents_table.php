<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('agents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('provider_id')->constrained('users');
            $table->decimal('commission_pct', 5, 2)->default(2.00);
            $table->decimal('total_earned', 12, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('agents'); }
};
