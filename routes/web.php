<?php

use App\Http\Controllers\LocaleController;
use App\Http\Controllers\ZodiacController;
use Illuminate\Support\Facades\Route;

Route::get('/locale/{locale}', [LocaleController::class, 'setLocale'])->name('locale.set');

// Redirect to Spanish by default if no language is specified
Route::get('/', function () {
    return redirect('/es');
});

Route::group(['prefix' => '{locale}', 'middleware' => 'setLocale'], function () {
    Route::get('/', function () {
        return view('index');
    })->name('horoscope.index');

    // Route for showing zodiac prediction
    Route::get('/{sign}', [ZodiacController::class, 'showSign'])->name('horoscope.show');
});

// Zodiac routes
Route::get('/zodiac', [ZodiacController::class, 'show'])->name('zodiac.show');
Route::get('/zodiac/import', [ZodiacController::class, 'importHoroscope'])->name('zodiac.import');
