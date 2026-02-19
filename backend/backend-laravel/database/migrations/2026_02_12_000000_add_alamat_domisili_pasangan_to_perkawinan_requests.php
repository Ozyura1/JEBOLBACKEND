<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            if (! Schema::hasColumn('perkawinan_requests', 'alamat_domisili_pasangan')) {
                $table->text('alamat_domisili_pasangan')->nullable()->after('alamat_domisili');
            }
        });
    }

    public function down()
    {
        Schema::table('perkawinan_requests', function (Blueprint $table) {
            if (Schema::hasColumn('perkawinan_requests', 'alamat_domisili_pasangan')) {
                $table->dropColumn('alamat_domisili_pasangan');
            }
        });
    }
};
