<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// Chit group templates created by super_admin
return new class extends Migration {
    public function up(): void {
        Schema::create('chit_packages', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->decimal('monthly_amount', 12, 2);
            $table->integer('duration_months');
            $table->integer('max_members');
            $table->decimal('commission_pct', 5, 2)->default(5.00);
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void { Schema::dropIfExists('chit_packages'); }
};
