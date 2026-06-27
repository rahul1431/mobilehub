<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('chit_groups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('package_id')->constrained('chit_packages');
            $table->foreignId('provider_id')->constrained('users');
            $table->string('name');
            $table->enum('status', ['forming', 'active', 'completed'])->default('forming');
            $table->integer('current_cycle')->default(0);
            $table->date('start_date')->nullable();
            $table->integer('total_members');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void { Schema::dropIfExists('chit_groups'); }
};
