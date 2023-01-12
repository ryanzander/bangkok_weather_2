import 'package:intl/intl.dart';

class Weather {
  final String name;
  final String description;
  final String imageUrl;
  final int temp;
  final int feelsLike;
  final int tempMin;
  final int tempMax;

  Weather({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? '';
    final List<dynamic> weather = json['weather'] ?? [];
    final dynamic currentWeather = weather[0] ?? {};
    final String description = toBeginningOfSentenceCase(
            (currentWeather['description'] ?? '').toString()) ??
        '';
    final String icon = currentWeather['icon'] ?? '01d';
    final String imageUrl = 'http://openweathermap.org/img/wn/$icon@2x.png';
    final dynamic main = json['main'] ?? {};
    final int temp = (main['temp'] ?? 0.0).round();
    final int feelsLike = (main['feels_like'] ?? 0.0).round();
    final int tempMin = (main['temp_min'] ?? 0.0).round();
    final int tempMax = (main['temp_max'] ?? 0.0).round();

    return Weather(
      description: description,
      name: name,
      imageUrl: imageUrl,
      temp: temp,
      feelsLike: feelsLike,
      tempMin: tempMin,
      tempMax: tempMax,
    );
  }
}
