<!DOCTYPE html>
<html lang="{{ $locale ?? 'en' }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zodiac Prediction - {{ ucfirst($sign ?? '') }}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background-image: url(https://wallpaper-house.com/data/out/7/wallpaper2you_173568.jpg);
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }
        .zodiac-card {
            margin: 2rem auto;
            max-width: 800px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .back-button {
            margin: 4rem 0;
        }
        .prediction-text {
            font-size: 1.1rem;
            line-height: 1.6;
            white-space: pre-line;
            padding: 1rem;
        }
        .back-arrow {
            font-size: 1.2rem;
            color: white;
            text-decoration: none;
            background-color: black;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 1px solid white;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.3s ease;
        }
        .back-arrow:hover {
            background-color: #333;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container py-4">
        @if(isset($error))
            <div class="alert alert-warning">
                {{ $error }}
            </div>
        @else
            <div class="back-button">
                <a href="{{ url()->previous() }}" class="back-arrow">
                    <i class="fas fa-arrow-left"></i>
                </a>
            </div>

            @foreach($data as $sign => $content)
                <div class="card zodiac-card">
                    <div class="card-header bg-primary text-white">
                        <h3 class="card-title mb-0 text-capitalize">
                            {{ __('signs.' . $sign) }}
                        </h3>
                    </div>
                    <div class="card-body">
                        <div class="prediction-text">
                            {!! nl2br(e($content['original'])) !!}
                        </div>
                    </div>
                </div>
            @endforeach
        @endif
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 