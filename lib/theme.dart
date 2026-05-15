import 'package:flutter/material.dart';

const _seed = Color(0xFF1FB76C); // pitch green

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed),
  fontFamily: 'SF Pro Text',
  appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ),
  fontFamily: 'SF Pro Text',
);
