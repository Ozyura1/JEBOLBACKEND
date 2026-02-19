<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add schedule fields to KTP submissions
        Schema::table('ktp_submissions', function (Blueprint $table) {
            $table->timestamp('scheduled_at')->nullable()->after('approved_at');
            $table->text('schedule_notes')->nullable()->after('scheduled_at');
        });

        // Add schedule fields to IKD submissions
        Schema::table('ikd_submissions', function (Blueprint $table) {
            $table->timestamp('scheduled_at')->nullable()->after('approved_at');
            $table->text('schedule_notes')->nullable()->after('scheduled_at');
        });
    }

    public function down(): void
    {
        Schema::table('ktp_submissions', function (Blueprint $table) {
            $table->dropColumn(['scheduled_at', 'schedule_notes']);
        });

        Schema::table('ikd_submissions', function (Blueprint $table) {
            $table->dropColumn(['scheduled_at', 'schedule_notes']);
        });
    }
};
