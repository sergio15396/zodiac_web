<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // If zodiacs table already exists, do nothing
        if (Schema::hasTable('zodiacs')) {
            return;
        }

        // First check if horoscopes table exists and rename it
        if (Schema::hasTable('horoscopes')) {
            Schema::rename('horoscopes', 'zodiacs');
        } else {
            // If no horoscopes table exists, create zodiacs table
            Schema::create('zodiacs', function (Blueprint $table) {
                $table->id();
                $table->date('date');
                $table->string('lang', 2);
                $table->string('sign');
                $table->string('time');
                $table->text('phrase');
                $table->timestamps();

                // Add foreign key constraint for lang
                $table->foreign('lang')
                      ->references('code')
                      ->on('langs')
                      ->onDelete('cascade');

                // Add indexes for better performance
                $table->index(['sign', 'lang', 'date', 'time']);
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('zodiacs')) {
            Schema::dropIfExists('zodiacs');
        }
    }
}; 