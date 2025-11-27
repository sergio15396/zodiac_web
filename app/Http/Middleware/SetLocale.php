<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;

class SetLocale
{   
    public function handle(Request $request, Closure $next)
    {   
        $locale = $request->route('locale');

        if (!in_array($locale, array_keys(config('locales.supported')))) {
            $locale = config('app.locale');
        }

        app()->setLocale($locale);

        return $next($request);
    }

}
