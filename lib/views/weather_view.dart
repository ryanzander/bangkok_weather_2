import 'package:flutter/material.dart';
import 'package:bangkok_weather/models/weather.dart';
import 'package:bangkok_weather/services/weather_service.dart';

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
      backgroundColor: Colors.blue,
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
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    ' ${(currentWeather?.temp ?? '')}°',
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${(currentWeather?.tempMin ?? '')}-${(currentWeather?.tempMax ?? '')}°',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade200,
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
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                        color: Colors.blue.shade200,
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
