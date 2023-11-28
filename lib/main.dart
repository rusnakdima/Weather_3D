import 'package:flutter/material.dart';
import 'shared/app_theme.dart';

import 'pages/home.dart';
import 'package:weather_3d/pages/forecast.dart';
import 'package:weather_3d/pages/search.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/forecast': (context) => const Forecast(),
        '/search': (context) => const Search()
      },
    );
  }
}
