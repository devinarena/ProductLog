import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:purchase_log/settings.dart';

/// Class  : Themes
/// Author : Devin Arena
/// Date   : 7/18/2021
/// Purpose: Contains theme information for the application (allows users to change theme)
class Themes with ChangeNotifier {
  static String _theme = "";

  static late Map<int, Color> color;

  static late ThemeData light;

  static late ThemeData dark;

  /// Sets up the primary color and theme data.
  static void init() {
    _theme = Settings.theme;
    color = {
      50: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .1),
      100: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .2),
      200: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .3),
      300: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .4),
      400: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .5),
      500: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .6),
      600: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .7),
      700: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .8),
      800: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          .9),
      900: Color.fromRGBO(
          Settings.themeColor & 0xFF,
          (Settings.themeColor >> 8) & 0xFF,
          (Settings.themeColor >> 16) & 0xFF,
          1),
    };
    light = ThemeData(
        primarySwatch: MaterialColor(Settings.themeColor, color),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light);
    dark = ThemeData(
        primarySwatch: MaterialColor(Settings.themeColor, color),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark);
  }

  /// Specifies whether or not the dark theme is used
  ///
  /// @returns bool true if _theme is Dark, false otherwise
  static bool isDark() =>
      _theme == "Dark" ||
      (_theme == "Device" &&
          SchedulerBinding.instance!.window.platformBrightness ==
              Brightness.dark);

  /// For the light theme a darker yellow must be used to make it easier to see.
  ///
  /// @returns Color light yellow if dark theme, dark yellow if light theme
  static Color yellow() => isDark() ? Colors.yellow[300]! : Colors.yellow[900]!;

  /// Light theme has much lighter containers than dark theme.
  ///
  /// @returns Color light grey if light theme, dark gray if dark theme
  static Color containerColor() =>
      isDark() ? Colors.grey[700]! : Colors.grey[300]!;

  /// Returns the current theme.
  ///
  /// @returns ThemeMode darkmode if dark theme is being used, lightmode otherwise
  ThemeMode currentTheme() {
    if (_theme == "Device") return ThemeMode.system;
    return isDark() ? ThemeMode.dark : ThemeMode.light;
  }

  /// Sets the theme to the designated theme (will always be Light, Dark, or Device)
  /// and notifies the listeners (homepage).
  ///
  /// @param theme String theme name (will always be Light, Dark, or Device)
  void setTheme(String theme) {
    _theme = theme;
    notifyListeners();
  }
}
