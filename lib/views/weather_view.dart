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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  int _counter = 0;
  final weatherService = WeatherService();
  Weather? currentWeather;

  @override
  initState() {
    super.initState();
    loadWeatherData();
  }

  void _incrementCounter() {
    setState(() {
      loadWeatherData();
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void loadWeatherData() async {
    currentWeather = await weatherService.fetchWeather();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Bangkok Weather'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              currentWeather?.name ?? '',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              currentWeather?.description ?? '',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
