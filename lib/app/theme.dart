// Tema visual global do app.
//
// Centraliza cores, tipografia e formas para garantir consistência.
// Altere apenas aqui — nunca hardcode cores nas telas.
//
// Mesmo visual da interface web do ESP32 (web/index.html no firmware), baseado
// no Modo Campanha: fundo tinta, texto creme, destaque laranja, cantos retos
// e fonte pixel (Pixelify Sans, SIL Open Font License) nos títulos.

import 'package:flutter/material.dart';

/// Cores do Modo Campanha — os mesmos tokens do CSS da página do aparelho.
abstract final class AppCores {
  static const fundo = Color(0xFF14110F);
  static const superficie = Color(0xFF1D1815);
  static const painel = Color(0xFF231F1C);
  static const elevado = Color(0xFF2B2521);
  static const texto = Color(0xFFF3E9D2);
  static const texto2 = Color(0xFFD7CBB5);
  static const apagado = Color(0xFFA89A86);
  static const borda = Color(0x1FF3E9D2); // texto a 12%
  static const bordaForte = Color(0x66F3E9D2); // texto a 40%
  static const destaque = Color(0xFFF28C28);
  static const destaqueClaro = Color(0xFFFFB357);
  static const destaqueEscuro = Color(0xFFC96A1B);
  static const brilho = Color(0x3DF28C28); // destaque a 24%
  static const ok = Color(0xFF7FB069);
  static const perigo = Color(0xFFC44536);
  static const perigoTexto = Color(0xFFE07A5F);
  static const aviso = Color(0xFFF2C14E);
  static const ledApagado = Color(0xFF3A332D);
}

/// Família da fonte pixel declarada no pubspec.yaml.
const String fontePixel = 'PixelifySans';

/// Fonte do texto corrido: a mesma que o Material usa no Android. Explícita nos
/// estilos de componente (botões, listas), que não herdam a fonte do tema.
const String fonteTexto = 'Roboto';

/// Raio padrão: cantos quase retos, como na página.
const double raio = 4;

/// Rótulo em caixa alta com espaçamento (ex.: "NOME", "IMAGEM", títulos de seção).
const TextStyle estiloRotulo = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.4,
  color: AppCores.destaque,
);

final _cantos = RoundedRectangleBorder(borderRadius: BorderRadius.circular(raio));

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: fonteTexto,
  colorScheme: const ColorScheme.dark(
    primary: AppCores.destaque,
    onPrimary: AppCores.fundo,
    primaryContainer: AppCores.destaqueEscuro,
    onPrimaryContainer: AppCores.texto,
    secondary: AppCores.destaqueClaro,
    onSecondary: AppCores.fundo,
    tertiary: AppCores.ok,
    error: AppCores.perigo,
    onError: AppCores.texto,
    surface: AppCores.superficie,
    onSurface: AppCores.texto,
    onSurfaceVariant: AppCores.texto2,
    surfaceContainerLowest: AppCores.fundo,
    surfaceContainerLow: AppCores.superficie,
    surfaceContainer: AppCores.painel,
    surfaceContainerHigh: AppCores.elevado,
    surfaceContainerHighest: AppCores.elevado,
    outline: AppCores.bordaForte,
    outlineVariant: AppCores.borda,
  ),
  scaffoldBackgroundColor: AppCores.fundo,
  dividerTheme: const DividerThemeData(color: AppCores.borda, space: 1),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppCores.fundo,
    surfaceTintColor: Colors.transparent,
    foregroundColor: AppCores.texto,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 15),
    bodySmall: TextStyle(fontSize: 13, color: AppCores.apagado),
    titleSmall: estiloRotulo,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppCores.destaque,
      foregroundColor: AppCores.fundo,
      disabledBackgroundColor: const Color(0x0AF3E9D2),
      disabledForegroundColor: AppCores.apagado,
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      textStyle: const TextStyle(fontFamily: fonteTexto, fontSize: 15, fontWeight: FontWeight.w600),
      shape: _cantos,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppCores.texto,
      side: const BorderSide(color: AppCores.bordaForte),
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      textStyle: const TextStyle(fontFamily: fonteTexto, fontSize: 15, fontWeight: FontWeight.w600),
      shape: _cantos,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppCores.destaque,
      textStyle: const TextStyle(fontFamily: fonteTexto, fontWeight: FontWeight.w600),
      shape: _cantos,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: AppCores.texto2, shape: _cantos),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppCores.superficie,
    hintStyle: const TextStyle(color: AppCores.apagado),
    counterStyle: const TextStyle(color: AppCores.apagado),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(raio),
      borderSide: const BorderSide(color: AppCores.bordaForte),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(raio),
      borderSide: const BorderSide(color: AppCores.bordaForte),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(raio),
      borderSide: const BorderSide(color: AppCores.destaque, width: 1.5),
    ),
  ),
  cardTheme: CardThemeData(
    color: AppCores.superficie,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(raio),
      side: const BorderSide(color: AppCores.borda),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppCores.elevado,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(raio),
      side: const BorderSide(color: AppCores.bordaForte),
    ),
    titleTextStyle: const TextStyle(
      fontFamily: fontePixel,
      fontSize: 20,
      fontVariations: [FontVariation.weight(500)],
      color: AppCores.texto,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppCores.elevado,
    contentTextStyle: const TextStyle(fontFamily: fonteTexto, color: AppCores.texto, fontSize: 14),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(raio),
      side: const BorderSide(color: AppCores.bordaForte),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? AppCores.fundo : AppCores.apagado,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? AppCores.destaque : AppCores.elevado,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? AppCores.destaque : AppCores.bordaForte,
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppCores.destaque),
  listTileTheme: const ListTileThemeData(
    iconColor: AppCores.texto2,
    titleTextStyle: TextStyle(fontFamily: fonteTexto, fontSize: 16, color: AppCores.texto),
    subtitleTextStyle: TextStyle(fontFamily: fonteTexto, fontSize: 13, color: AppCores.apagado),
  ),
);
