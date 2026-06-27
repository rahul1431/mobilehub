<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->string('name');               // Bronze, Silver, Gold
            $table->decimal('price', 10, 2);      // 499, 999, 2499
            $table->integer('group_limit');        // 5, 15, -1 (unlimited)
            $table->integer('member_limit');       // 100, 500, -1 (unlimited)
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('subscription_plans'); }
};
