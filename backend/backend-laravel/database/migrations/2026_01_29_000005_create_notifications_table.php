<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->unsignedBigInteger('user_id');
            $table->string('type'); // ktp_approved, ktp_scheduled, ikd_approved, ikd_scheduled
            $table->string('title');
            $table->text('message');
            $table->uuid('submission_id'); // ID dari KtpSubmission atau IkdSubmission
            $table->string('submission_type'); // 'ktp' or 'ikd'
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index('user_id');
            $table->index('submission_id');
            $table->index('read_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
