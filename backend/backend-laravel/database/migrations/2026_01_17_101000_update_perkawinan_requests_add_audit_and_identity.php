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
                $table->string('nik_pemohon', 16)->after('id');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'nik_pasangan')) {
                $table->string('nik_pasangan', 16)->after('nik_pemohon');
            }
            // align with app code using 'alamat_domisili'
            if (! Schema::hasColumn('perkawinan_requests', 'alamat_domisili')) {
                $table->text('alamat_domisili')->nullable()->after('nik_pasangan');
            }
            if (! Schema::hasColumn('perkawinan_requests', 'no_hp_pemohon')) {
                $table->string('no_hp_pemohon', 32)->nullable()->after('alamat_domisili');
            }

            // optional documents payload
            if (! Schema::hasColumn('perkawinan_requests', 'dokumen')) {
                $table->json('dokumen')->nullable()->after('tempat_perkawinan');
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

        // Ensure enum default is PENDING at DB level (only for DBs that support ALTER MODIFY)
        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE `perkawinan_requests` MODIFY COLUMN `status` ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING';");
        }

        // Add indexes for performance where applicable
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            if (! Schema::hasColumn('perkawinan_requests', 'status')) {
                // no-op safeguard; status expected to exist
            }
            // indexes (wrapped in try-catch-like by using DB operations)
            try { $table->index('status', 'pr_status_idx'); } catch (\Throwable $e) {}
            try { $table->index('nik_pemohon', 'pr_nik_pemohon_idx'); } catch (\Throwable $e) {}
            try { $table->index('created_at', 'pr_created_at_idx'); } catch (\Throwable $e) {}
        });

        // Add FK constraint for verified_by_user_id if not exists
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            // create foreign key if column exists and FK not yet present
            try {
                $table->foreign('verified_by_user_id', 'pr_verified_by_fk')
                    ->references('id')->on('users')
                    ->nullOnDelete();
            } catch (\Throwable $e) {
                // ignore if already exists
            }
        });
    }

    public function down()
    {
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            // drop FK if present
            try { $table->dropForeign('pr_verified_by_fk'); } catch (\Throwable $e) {}

            if (Schema::hasColumn('perkawinan_requests', 'nik_pemohon')) {
                $table->dropColumn('nik_pemohon');
            }
            if (Schema::hasColumn('perkawinan_requests', 'nik_pasangan')) {
                $table->dropColumn('nik_pasangan');
            }
            if (Schema::hasColumn('perkawinan_requests', 'alamat_domisili')) {
                $table->dropColumn('alamat_domisili');
            }
            if (Schema::hasColumn('perkawinan_requests', 'no_hp_pemohon')) {
                $table->dropColumn('no_hp_pemohon');
            }
            if (Schema::hasColumn('perkawinan_requests', 'dokumen')) {
                $table->dropColumn('dokumen');
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

        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            DB::statement("ALTER TABLE `perkawinan_requests` MODIFY COLUMN `status` ENUM('PENDING','VERIFIED','REJECTED') NOT NULL DEFAULT 'PENDING';");
        }
    }
};
