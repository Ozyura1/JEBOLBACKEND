<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('ktp_submissions', function (Blueprint $table) {
            $table->enum('kategori', ['umum', 'khusus'])->default('umum')->after('nomor_telp');
            $table->enum('kategori_khusus', ['lansia', 'odgj'])->nullable()->after('kategori');
            $table->integer('minimal_usia')->default(16)->after('kategori_khusus');
        });
    }

    public function down(): void
    {
        Schema::table('ktp_submissions', function (Blueprint $table) {
            $table->dropColumn(['kategori', 'kategori_khusus', 'minimal_usia']);
        });
    }
};
