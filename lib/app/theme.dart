// Tema visual global do app.
//
// Centraliza cores, tipografia e formas para garantir consistência.
// Altere apenas aqui — nunca hardcode cores nas telas.
//
// Cor semente: roxo escuro (#4A1080), evocando estética retrô de consoles.

import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4A1080),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF171212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF171212),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF2A2020),
  ),
);
