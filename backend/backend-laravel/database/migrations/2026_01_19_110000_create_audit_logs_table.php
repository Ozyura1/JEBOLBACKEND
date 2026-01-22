<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable()->index();
            $table->string('action', 100);
            $table->string('auditable_type')->nullable();
            $table->unsignedBigInteger('auditable_id')->nullable()->index();
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            $table->string('ip_address')->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();

            try {
                $table->foreign('user_id', 'audit_logs_user_fk')->references('id')->on('users')->nullOnDelete();
            } catch (\Throwable $e) {
                // ignore when running in sqlite memory or if FK already exists
            }
        });
    }

    public function down()
    {
        Schema::table('audit_logs', function (Blueprint $table) {
            try { $table->dropForeign('audit_logs_user_fk'); } catch (\Throwable $e) {}
        });
        Schema::dropIfExists('audit_logs');
    }
};
