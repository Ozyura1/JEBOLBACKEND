<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            if (! Schema::hasColumn('perkawinan_requests', 'no_hp_pasangan')) {
                $table->string('no_hp_pasangan', 32)->nullable()->after('no_hp_pemohon');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'alamat_domisili')) {
                $table->text('alamat_domisili')->nullable()->after('nik_pasangan');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'tempat_perkawinan')) {
                $table->string('tempat_perkawinan', 255)->nullable()->after('tanggal_perkawinan');
            }
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE `perkawinan_requests` MODIFY COLUMN `status` ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING';");
        }
    }

    public function down()
    {
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            if (Schema::hasColumn('perkawinan_requests', 'no_hp_pasangan')) {
                $table->dropColumn('no_hp_pasangan');
            }
            if (Schema::hasColumn('perkawinan_requests', 'alamat_domisili')) {
                $table->dropColumn('alamat_domisili');
            }
            if (Schema::hasColumn('perkawinan_requests', 'tempat_perkawinan')) {
                $table->dropColumn('tempat_perkawinan');
            }
        });

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE `perkawinan_requests` MODIFY COLUMN `status` ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING';");
        }
    }
};
