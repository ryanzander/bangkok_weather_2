import 'dart:convert';
import 'dart:developer';
import 'package:bangkok_weather/api_urls.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

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
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ),
                  Text(
                    ' ${(currentWeather?.temp ?? '')}°',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  Text(
                    '${(currentWeather?.tempMin ?? '')}-${(currentWeather?.tempMax ?? '')}°',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade100,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      currentWeather?.description ?? '',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                    ),
                    child: Text(
                      'Feels like: ${(currentWeather?.feelsLike ?? '')}°',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade100,
                      ),
                    ),
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
  /// Returns a Weather model
  Future<Weather?> fetchWeather() async {
    // First we need to get the device location
    final Position position = await _determinePosition();
    final String lat = position.latitude.toString();
    final String lon = position.longitude.toString();

    // Use the lat and lon to construct the url and make a GET request
    final String weatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$appId&units=metric';
    final Uri uri = Uri.parse(weatherUrl);
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      // Parse a Weather model from the json for a success response
      String data = response.body;
      var json = jsonDecode(data);
      final Weather weather = Weather.fromJson(json);
      return weather;
    } else {
      log('Request failed with status: ${response.statusCode}.');
      return null;
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}

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
