<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Zodiac extends Model
{
    protected $fillable = [
        'date',
        'lang',
        'sign',
        'time',
        'phrase'
    ];

    protected $casts = [
        'date' => 'date'
    ];

    public function language()
    {
        return $this->belongsTo(Lang::class, 'lang', 'code');
    }
} 