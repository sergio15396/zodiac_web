<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\App;

class LocaleController extends Controller
{   
    public function setLocale($locale)
    {
        if (!in_array($locale, array_keys(config('locales.supported')))) {
            abort(400, 'Locale not supported.');
        }

        App::setLocale($locale);

        session(['locale' => $locale]);

        return redirect()->back();
    }
}
