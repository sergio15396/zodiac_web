<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lang extends Model
{
    protected $fillable = ['code', 'name'];

    public function zodiacs()
    {
        return $this->hasMany(Zodiac::class, 'lang', 'code');
    }
}
