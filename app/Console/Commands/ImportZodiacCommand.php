<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Zodiac;
use App\Models\Lang;
use Illuminate\Support\Facades\Http;
use Stichoza\GoogleTranslate\GoogleTranslate;

class ImportZodiacCommand extends Command
{
    protected $signature = 'zodiac:import-all';
    protected $description = 'Import horoscopes for all zodiac signs and translate them to all languages';

    public function handle()
    {
        $this->info('Starting horoscope import...');

        $signs = [
            'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
            'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
        ];

        $langs = Lang::all();
        $date = now()->format('Y-m-d');
        $time = 'today';

        foreach ($signs as $sign) {
            $this->info("Processing {$sign}...");

            try {
                // Fetch from API
                $response = Http::get("https://www.zodiacsign.com/api/call.php", [
                    'time' => $time,
                    'sign' => $sign
                ]);

                if (!$response->successful()) {
                    $this->error("Failed to fetch horoscope for {$sign}");
                    continue;
                }

                $content = $response->body();
                
                if (empty($content)) {
                    $this->error("Empty response for {$sign}");
                    continue;
                }

                // Store English version
                Zodiac::create([
                    'date' => $date,
                    'lang' => 'en',
                    'sign' => $sign,
                    'time' => $time,
                    'phrase' => $content
                ]);

                $this->info("Stored English version for {$sign}");

                // Translate and store in other languages
                foreach ($langs as $lang) {
                    if ($lang->code !== 'en') {
                        try {
                            $translated = GoogleTranslate::trans($content, $lang->code, 'en');
                            
                            Zodiac::create([
                                'date' => $date,
                                'lang' => $lang->code,
                                'sign' => $sign,
                                'time' => $time,
                                'phrase' => $translated
                            ]);

                            $this->info("Translated and stored {$sign} in {$lang->name}");
                        } catch (\Exception $e) {
                            $this->error("Failed to translate {$sign} to {$lang->name}: " . $e->getMessage());
                        }
                    }
                }

            } catch (\Exception $e) {
                $this->error("Error processing {$sign}: " . $e->getMessage());
            }
        }

        $this->info('Horoscope import completed!');
    }
} 