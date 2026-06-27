<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('cycles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained('chit_groups')->cascadeOnDelete();
            $table->integer('cycle_number');
            $table->date('due_date');
            $table->decimal('total_pot', 12, 2);
            $table->decimal('winning_bid', 12, 2)->nullable();
            $table->foreignId('winner_id')->nullable()->constrained('users')->nullOnDelete();
            $table->decimal('dividend_per_member', 12, 2)->nullable();
            $table->enum('cycle_method', ['auction', 'lottery', 'manual'])->default('manual');
            $table->enum('status', ['open', 'auction', 'closed'])->default('open');
            $table->timestamp('closed_at')->nullable();
            $table->timestamps();

            $table->unique(['group_id', 'cycle_number']);
        });
    }

    public function down(): void { Schema::dropIfExists('cycles'); }
};
