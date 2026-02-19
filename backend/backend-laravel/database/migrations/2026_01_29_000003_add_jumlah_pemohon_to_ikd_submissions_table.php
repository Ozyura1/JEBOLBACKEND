<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('ikd_submissions', function (Blueprint $table) {
            $table->integer('jumlah_pemohon')->default(1)->after('alamat_manual');
        });
    }

    public function down(): void
    {
        Schema::table('ikd_submissions', function (Blueprint $table) {
            $table->dropColumn('jumlah_pemohon');
        });
    }
};
