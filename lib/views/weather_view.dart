import 'dart:convert';
import 'dart:developer';
import 'package:bangkok_weather/api_urls.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherView extends StatefulWidget {
  const WeatherView({
    super.key,
  });

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  bool isLoading = false;
  final weatherService = WeatherService();
  Weather? currentWeather;

  @override
  initState() {
    super.initState();
    loadWeatherData();
  }

  void loadWeatherData() async {
    setState(() {
      isLoading = true;
    });

    currentWeather = await weatherService.fetchWeather();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade300,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      currentWeather?.name ?? '',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      currentWeather?.description ?? '',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: currentWeather != null
                        ? Image.network(
                            currentWeather!.imageUrl,
                          )
                        : const Offstage(),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadWeatherData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class WeatherService {
  final String lat = '13.75';
  final String lon = '100.5167';

  Future<Weather?> fetchWeather() async {
    final String weatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$appId&units=metric';

    final Uri uri = Uri.parse(weatherUrl);

    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      String data = response.body;
      var json = jsonDecode(data);
      final Weather weather = Weather.fromJson(json);
      return weather;
    } else {
      log('Request failed with status: ${response.statusCode}.');
      return null;
    }
  }
}

class Weather {
  final String name;
  final String description;

  final String imageUrl;

  Weather(
      {required this.name, required this.description, required this.imageUrl});

  factory Weather.fromJson(Map<String, dynamic> json) {
    final String _name = json['name'] ?? '';
    final List<dynamic> _weather = json['weather'] ?? [];
    final dynamic _currentWeather = _weather[0] ?? {};
    final String _description = toBeginningOfSentenceCase(
            (_currentWeather['description'] ?? '').toString()) ??
        '';
    final String _icon = _currentWeather['icon'] ?? '01d';

    final String _imageUrl = 'http://openweathermap.org/img/wn/$_icon@2x.png';

    return Weather(
      description: _description,
      name: _name,
      imageUrl: _imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'name': name,
      };
}
