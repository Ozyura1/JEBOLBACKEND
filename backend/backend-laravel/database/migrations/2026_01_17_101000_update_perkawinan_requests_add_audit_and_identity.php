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
            // identity fields for warga (no FK to users)
            if (! Schema::hasColumn('perkawinan_requests', 'nik_pemohon')) {
                $table->string('nik_pemohon', 32)->after('id');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'nik_pasangan')) {
                $table->string('nik_pasangan', 32)->after('nik_pemohon');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'alamat')) {
                $table->text('alamat')->nullable()->after('nik_pasangan');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'no_hp_pemohon')) {
                $table->string('no_hp_pemohon', 32)->nullable()->after('alamat');
            }

            // audit fields
            if (! Schema::hasColumn('perkawinan_requests', 'verified_by_user_id')) {
                $table->unsignedBigInteger('verified_by_user_id')->nullable()->after('status');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'catatan_admin')) {
                $table->text('catatan_admin')->nullable()->after('verified_by_user_id');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'verified_at')) {
                $table->timestamp('verified_at')->nullable()->after('catatan_admin');
            }
        });

        // Change enum default to SUBMITTED at DB level
        DB::statement("ALTER TABLE `perkawinan_requests` MODIFY COLUMN `status` ENUM('SUBMITTED','VERIFIED','REJECTED') NOT NULL DEFAULT 'SUBMITTED';");
    }

    public function down()
    {
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            if (Schema::hasColumn('perkawinan_requests', 'nik_pemohon')) {
                $table->dropColumn('nik_pemohon');
            }
            if (Schema::hasColumn('perkawinan_requests', 'nik_pasangan')) {
                $table->dropColumn('nik_pasangan');
            }
            if (Schema::hasColumn('perkawinan_requests', 'alamat')) {
                $table->dropColumn('alamat');
            }
            if (Schema::hasColumn('perkawinan_requests', 'no_hp_pemohon')) {
                $table->dropColumn('no_hp_pemohon');
            }
            if (Schema::hasColumn('perkawinan_requests', 'verified_by_user_id')) {
                $table->dropColumn('verified_by_user_id');
            }
            if (Schema::hasColumn('perkawinan_requests', 'catatan_admin')) {
                $table->dropColumn('catatan_admin');
            }
            if (Schema::hasColumn('perkawinan_requests', 'verified_at')) {
                $table->dropColumn('verified_at');
            }
        });

        DB::statement("ALTER TABLE `perkawinan_requests` MODIFY COLUMN `status` ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING';");
    }
};
