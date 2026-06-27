<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('group_memberships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained('chit_groups')->cascadeOnDelete();
            $table->foreignId('member_id')->constrained('users');
            $table->integer('membership_no');       // slot position 1..N
            $table->boolean('has_won')->default(false);
            $table->boolean('is_active')->default(true);
            $table->string('mandate_id')->nullable(); // Razorpay eNACH mandate
            $table->timestamps();

            $table->unique(['group_id', 'member_id']);
            $table->unique(['group_id', 'membership_no']);
        });
    }

    public function down(): void { Schema::dropIfExists('group_memberships'); }
};
