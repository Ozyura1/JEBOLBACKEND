<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // For MySQL, alter the enum column to include 'scheduled'.
        // SQLite does not support MODIFY/ENUM — skip in SQLite (no-op).
        if (DB::getDriverName() === 'mysql') {
            // Update KTP submissions status enum to include 'scheduled'
            DB::statement("ALTER TABLE `ktp_submissions` MODIFY COLUMN `status` ENUM('pending', 'approved', 'rejected', 'scheduled') NOT NULL DEFAULT 'pending'");

            // Update IKD submissions status enum to include 'scheduled'
            DB::statement("ALTER TABLE `ikd_submissions` MODIFY COLUMN `status` ENUM('pending', 'approved', 'rejected', 'scheduled') NOT NULL DEFAULT 'pending'");
        }
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'mysql') {
            // Rollback: remove 'scheduled' from enum
            DB::statement("ALTER TABLE `ktp_submissions` MODIFY COLUMN `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending'");

            DB::statement("ALTER TABLE `ikd_submissions` MODIFY COLUMN `status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending'");
        }
    }
};

