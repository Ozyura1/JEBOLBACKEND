<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add alamat_lokasi field to KTP submissions
        Schema::table('ktp_submissions', function (Blueprint $table) {
            $table->text('alamat_lokasi')->nullable()->after('alamat_manual');
        });

        // Add alamat_lokasi field to IKD submissions
        Schema::table('ikd_submissions', function (Blueprint $table) {
            $table->text('alamat_lokasi')->nullable()->after('alamat_manual');
        });
    }

    public function down(): void
    {
        Schema::table('ktp_submissions', function (Blueprint $table) {
            $table->dropColumn('alamat_lokasi');
        });

        Schema::table('ikd_submissions', function (Blueprint $table) {
            $table->dropColumn('alamat_lokasi');
        });
    }
};
