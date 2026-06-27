<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('penalty_rules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('provider_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->integer('grace_days')->default(3);
            $table->decimal('flat_penalty', 10, 2)->default(0);
            $table->decimal('pct_penalty', 5, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('penalty_rules'); }
};
