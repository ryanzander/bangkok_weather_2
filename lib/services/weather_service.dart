import 'dart:convert';
import 'dart:developer';
import 'package:bangkok_weather/api_keys.dart';
import 'package:bangkok_weather/models/weather.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

class WeatherService {
  /// Returns a Weather model or null
  Future<Weather?> fetchWeather() async {
    // Start by checking for location permission
    final bool hasPermission = await _handlePermission();
    if (!hasPermission) return null;

    // We have permission, so get the device location
    final Position position = await Geolocator.getCurrentPosition();
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

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Then check permission and request if currently denied
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // We have permission if we have gotton this far
    return true;
  }
}
