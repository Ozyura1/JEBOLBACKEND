<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('perkawinan_requests', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->uuid('uuid')->unique();
            $table->string('nama_pemohon');
            $table->string('nama_pasangan');
            $table->date('tanggal_perkawinan');
            $table->string('tempat')->nullable();
            $table->json('dokumen')->nullable();
            $table->enum('status', ['PENDING','VERIFIED','REJECTED'])->default('PENDING');
            $table->string('verified_by_uuid')->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('perkawinan_requests');
    }
};
