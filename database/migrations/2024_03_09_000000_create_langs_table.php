<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // If langs table already exists, do nothing
        if (Schema::hasTable('langs')) {
            return;
        }

        Schema::create('langs', function (Blueprint $table) {
            $table->id();
            $table->string('code', 2)->unique();
            $table->string('name');
            $table->timestamps();
        });

        // Insert default languages
        DB::table('langs')->insert([
            ['code' => 'en', 'name' => 'English', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'es', 'name' => 'Spanish', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'fr', 'name' => 'French', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'de', 'name' => 'German', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'it', 'name' => 'Italian', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'pt', 'name' => 'Portuguese', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'ru', 'name' => 'Russian', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'ja', 'name' => 'Japanese', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'pl', 'name' => 'Polish', 'created_at' => now(), 'updated_at' => now()],
            ['code' => 'nl', 'name' => 'Dutch', 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    public function down()
    {
        Schema::dropIfExists('langs');
    }
}; 