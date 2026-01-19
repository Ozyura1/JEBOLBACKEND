<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->char('uuid', 36)->unique()->nullable();
            $table->string('username', 191)->unique();
            $table->string('password');
            $table->enum('role', [
                'SUPER_ADMIN',
                'ADMIN_KTP',
                'ADMIN_IKD',
                'ADMIN_PERKAWINAN',
                'RT'
            ]);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            // Indexes
            $table->index('role');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
