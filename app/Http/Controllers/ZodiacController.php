<?php

namespace App\Http\Controllers;

use App\Models\Zodiac;
use App\Models\Lang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Stichoza\GoogleTranslate\GoogleTranslate;

class ZodiacController extends Controller
{
    protected $zodiacSigns = [
        'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
        'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
    ];

    public function show()
    {
        try {
            $data = json_decode(Storage::get('zodiac/all_signs_today.json'), true);
            return view('zodiac.show', compact('data'));
        } catch (\Exception $e) {
            Log::error('Error in show method: ' . $e->getMessage());
            return view('zodiac.show', ['error' => 'No zodiac data available. Please run the import command first.']);
        }
    }

    public function showSign($locale, $sign)
    {
        try {
            // Set the application locale
            app()->setLocale($locale);

            // Validate sign
            if (!in_array(strtolower($sign), $this->zodiacSigns)) {
                Log::warning('Invalid zodiac sign requested: ' . $sign);
                return view('zodiac.show', ['error' => 'Invalid zodiac sign: ' . $sign]);
            }

            $time = 'today';

            Log::info("Looking for horoscope with params:", [
                'sign' => $sign,
                'locale' => $locale,
                'time' => $time
            ]);

            // Check if we have the horoscope in the database
            $zodiac = Zodiac::where('sign', strtolower($sign))
                          ->where('lang', $locale)
                          ->where('time', $time)
                          ->orderBy('date', 'desc')
                          ->first();

            if (!$zodiac) {
                Log::info("No horoscope found in database, fetching from API");
                // If not in database, fetch from API
                $response = Http::get("https://www.zodiacsign.com/api/call.php", [
                    'time' => $time,
                    'sign' => strtolower($sign)
                ]);

                if (!$response->successful()) {
                    Log::error('API request failed for sign ' . $sign . ': ' . $response->status());
                    return view('zodiac.show', ['error' => 'Unable to fetch horoscope for ' . $sign . '. Please try again later.']);
                }

                $content = $response->body();
                
                if (empty($content)) {
                    Log::error('Empty response from API for sign: ' . $sign);
                    return view('zodiac.show', ['error' => 'Received empty horoscope for ' . $sign . '. Please try again later.']);
                }

                Log::info("Storing English version in database");
                // Store English version
                Zodiac::create([
                    'date' => now(),
                    'lang' => 'en',
                    'sign' => strtolower($sign),
                    'time' => $time,
                    'phrase' => $content
                ]);

                Log::info("Translating to other languages");
                // Get all languages and translate
                $langs = Lang::all();
                foreach ($langs as $lang) {
                    if ($lang->code !== 'en') {
                        try {
                            $translated = GoogleTranslate::trans($content, $lang->code, 'en');
                            Log::info("Translated to {$lang->code}");
                            
                            Zodiac::create([
                                'date' => now(),
                                'lang' => $lang->code,
                                'sign' => strtolower($sign),
                                'time' => $time,
                                'phrase' => $translated
                            ]);
                        } catch (\Exception $e) {
                            Log::error("Translation failed for {$lang->code}: " . $e->getMessage());
                        }
                    }
                }

                // Get the requested language version
                $zodiac = Zodiac::where('sign', strtolower($sign))
                              ->where('lang', $locale)
                              ->where('time', $time)
                              ->orderBy('date', 'desc')
                              ->first();
            }

            if (!$zodiac) {
                Log::error("Still no horoscope found after API fetch and translation");
                return view('zodiac.show', ['error' => 'No horoscope found for this combination.']);
            }

            Log::info("Found horoscope:", [
                'id' => $zodiac->id,
                'sign' => $zodiac->sign,
                'lang' => $zodiac->lang,
                'date' => $zodiac->date
            ]);

            $data = [
                $sign => [
                    'original' => $zodiac->phrase
                ]
            ];

            return view('zodiac.show', [
                'data' => $data,
                'locale' => $locale,
                'sign' => $sign
            ]);

        } catch (\Exception $e) {
            Log::error('Error in showSign method for sign ' . $sign . ': ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());
            return view('zodiac.show', ['error' => 'An error occurred while fetching the horoscope. Please try again later.']);
        }
    }

    public function importHoroscope()
    {
        $langs = Lang::all();
        $allData = [];
        
        foreach ($this->zodiacSigns as $sign) {
            try {
                // Fetch from API
                $response = Http::get("https://www.zodiacsign.com/api/call.php", [
                    'time' => 'today',
                    'sign' => $sign
                ]);

                if (!$response->successful()) {
                    Log::error('API request failed for sign ' . $sign . ': ' . $response->status());
                    continue;
                }

                $content = $response->body();
                
                if (empty($content)) {
                    Log::error('Empty response from API for sign: ' . $sign);
                    continue;
                }

                $date = now()->format('Y-m-d');

                // Store English version
                Zodiac::create([
                    'date' => $date,
                    'lang' => 'en',
                    'sign' => $sign,
                    'time' => 'today',
                    'phrase' => $content
                ]);

                // Translate and store in other languages
                foreach ($langs as $lang) {
                    if ($lang->code !== 'en') {
                        $translated = GoogleTranslate::trans($content, $lang->code, 'en');
                        Zodiac::create([
                            'date' => $date,
                            'lang' => $lang->code,
                            'sign' => $sign,
                            'time' => 'today',
                            'phrase' => $translated
                        ]);
                    }
                }

                // Add to all data array
                $allData[$sign] = [
                    'original' => $content
                ];

                Log::info('Successfully imported horoscope for sign: ' . $sign);

            } catch (\Exception $e) {
                Log::error('Error importing horoscope for sign ' . $sign . ': ' . $e->getMessage());
                continue;
            }
        }
        
        // Store all results in a single file
        Storage::put('zodiac/all_signs_today.json', json_encode($allData, JSON_PRETTY_PRINT));

        return response()->json(['message' => 'Horoscopes imported successfully']);
    }
} 