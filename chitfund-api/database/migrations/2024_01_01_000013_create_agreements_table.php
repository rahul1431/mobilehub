<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('agreements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained('chit_groups')->cascadeOnDelete();
            $table->foreignId('member_id')->constrained('users');
            $table->string('digio_doc_id')->nullable();
            $table->string('pdf_storage_path')->nullable();
            $table->timestamp('signed_at')->nullable();
            $table->timestamps();

            $table->unique(['group_id', 'member_id']);
        });
    }

    public function down(): void { Schema::dropIfExists('agreements'); }
};
