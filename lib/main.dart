import 'package:flutter/material.dart';
import 'views/weather_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangkok Weather',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const WeatherView(),
    );
  }
}
