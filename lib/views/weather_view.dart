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
