<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ __('horo.title') }} - @yield('title', __('horo.home'))</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background-color: #121638;
            color: #fff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            margin: 0;
        }
        .navbar {
            background-color: #1a1f4c !important;
        }
        .container {
            flex: 1;
        }
        .card {
            background-color: #1a1f4c;
            border: none;
            border-radius: 15px;
            box-shadow: 0 6px 12px rgba(0,0,0,0.2);
            margin-bottom: 20px;
            color: #ffffff;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card:hover {
            transform: translateY(-10px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.3);
        }
        .zodiac-icon {
            font-size: 3.5rem;
            margin-bottom: 15px;
            transition: transform 0.3s ease;
        }
        .card:hover .zodiac-icon {
            transform: scale(1.1);
        }
        .btn-primary {
            background-color: #7b5ee4;
            border-color: #7b5ee4;
        }
        .btn-primary:hover {
            background-color: #6447d1;
            border-color: #6447d1;
        }
        .language-select {
            background-color: #1a1f4c;
            border: 1px solid #7b5ee4;
            color: #ffffff;
            border-radius: 10px;
            padding: 8px 15px;
        }
        .language-select option {
            background-color: #1a1f4c;
            color: #ffffff;
        }
        .footer {
            background-color: #1a1f4c;
            padding: 20px 0;
            color: #ffffff;
            text-align: center;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
        <div class="container">
            <a class="navbar-brand" href="{{ route('horoscope.index', ['locale' => app()->getLocale()]) }}">
                <i class="fas fa-star"></i>
                {{ __('horo.title') }}
                <i class="fas fa-moon"></i>
            </a>
            <div class="ms-auto">
                <select class="language-select" id="languageSelect" onchange="window.location.href='/' + this.value;">
                    @foreach(config('locales.supported') as $code => $language)
                        <option value="{{ $code }}" {{ app()->getLocale() === $code ? 'selected' : '' }}>
                            {{ $language }}
                        </option>
                    @endforeach
                </select>
            </div>
        </div>
    </nav>

    <div class="container">
        @if(session('error'))
            <div class="alert alert-danger">
                {{ session('error') }}
            </div>
        @endif

        @yield('content')
    </div>

    <footer class="footer">
        <div class="container">
            <p>© {{ date('Y') }} {{ __('horo.title') }} Sergio Reyes</p>
            <p class="mt-3">
                @foreach(config('locales.supported') as $code => $lang)
                    <a href="{{ url($code) }}" class="text-white text-decoration-none mx-2 {{ app()->getLocale() == $code ? 'text-decoration-underline fw-bold' : '' }}">{{ $lang }}</a>     
                    
                    @if(!$loop->last) | @endif
                @endforeach
            </p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
