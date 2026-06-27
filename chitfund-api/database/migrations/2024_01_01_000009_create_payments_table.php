<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cycle_id')->constrained('cycles')->cascadeOnDelete();
            $table->foreignId('member_id')->constrained('users');
            $table->foreignId('group_id')->constrained('chit_groups');
            $table->decimal('amount', 12, 2);
            $table->enum('payment_method', ['upi', 'mandate', 'cash', 'bank_transfer', 'razorpay'])->default('razorpay');
            $table->string('razorpay_order_id')->nullable()->index();
            $table->string('razorpay_payment_id')->nullable();
            $table->enum('status', ['pending', 'paid', 'failed', 'refunded'])->default('pending');
            $table->decimal('penalty_amount', 10, 2)->default(0);
            $table->string('notes')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->unique(['cycle_id', 'member_id']);
        });
    }

    public function down(): void { Schema::dropIfExists('payments'); }
};
