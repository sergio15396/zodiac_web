@extends('layouts.app')

@section('title', __('horo.home'))

@section('content')
    <div class="row justify-content-center mb-4">
        <div class="col-md-8 text-center">
            <h1>{{ __('horo.title') }}</h1>
            <p class="lead text-muted" style="color: white !important">{{ __('horo.select_sign') }}</p>
        </div>
    </div>

    @php
        $zodiacSigns = [
            ['name' => 'aries', 'icon' => 'fas fa-fire', 'color' => '#ff4d4d'],
            ['name' => 'taurus', 'icon' => 'fas fa-circle', 'color' => '#66cc66'],
            ['name' => 'gemini', 'icon' => 'fas fa-yin-yang', 'color' => '#ffcc00'],
            ['name' => 'cancer', 'icon' => 'fas fa-water', 'color' => '#66ccff'],
            ['name' => 'leo', 'icon' => 'fas fa-sun', 'color' => '#ff9933'],
            ['name' => 'virgo', 'icon' => 'fas fa-leaf', 'color' => '#cc99ff'],
            ['name' => 'libra', 'icon' => 'fas fa-balance-scale', 'color' => '#ff99cc'],
            ['name' => 'scorpio', 'icon' => 'fas fa-dragon', 'color' => '#ff3366'],
            ['name' => 'sagittarius', 'icon' => 'fas fa-arrow-alt-circle-up', 'color' => '#9966ff'],
            ['name' => 'capricorn', 'icon' => 'fas fa-mountain', 'color' => '#666699'],
            ['name' => 'aquarius', 'icon' => 'fas fa-tint', 'color' => '#33ccff'],
            ['name' => 'pisces', 'icon' => 'fas fa-fish', 'color' => '#99ccff']
        ];
    @endphp

    <div class="row g-4 mb-5">
        @foreach($zodiacSigns as $sign)
        <div class="col-6 col-md-4 col-lg-3">
            <a href="{{ route('horoscope.show', ['locale' => app()->getLocale(), 'sign' => $sign['name']]) }}"
               class="card h-100 w-100 text-center text-decoration-none border-0"
               style="background: linear-gradient(145deg, {{ $sign['color'] }}22, {{ $sign['color'] }}44);">
                <div class="card-body">
                    <i class="{{ $sign['icon'] }} zodiac-icon" style="color: {{ $sign['color'] }}"></i>
                    <h4>{{ __('signs.' . $sign['name']) }}</h4>
                </div>
            </a>
        </div>
        @endforeach
    </div>
@endsection
