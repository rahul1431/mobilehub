<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('dividends', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cycle_id')->constrained('cycles')->cascadeOnDelete();
            $table->foreignId('member_id')->constrained('users');
            $table->decimal('amount', 12, 2);
            $table->enum('status', ['pending', 'disbursed'])->default('pending');
            $table->timestamp('disbursed_at')->nullable();
            $table->timestamps();

            $table->unique(['cycle_id', 'member_id']);
        });
    }

    public function down(): void { Schema::dropIfExists('dividends'); }
};
