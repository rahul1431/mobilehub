<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('bids', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cycle_id')->constrained('cycles')->cascadeOnDelete();
            $table->foreignId('member_id')->constrained('users');
            $table->decimal('bid_amount', 12, 2);
            $table->boolean('is_winning')->default(false);
            $table->timestamps();

            // One bid per member per cycle
            $table->unique(['cycle_id', 'member_id']);
        });
    }

    public function down(): void { Schema::dropIfExists('bids'); }
};
