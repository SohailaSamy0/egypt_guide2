import 'package:flutter/material.dart' hide Text;
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController._();

  static final AppSettingsController instance =
      AppSettingsController._();

  static const String _languageKey = 'app_language';
  static const String _themeKey = 'app_theme';

  final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;

  ThemeMode get themeMode => _themeMode;

  bool get isArabic => _locale.languageCode == 'ar';

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark;

  Future<void> loadSettings() async {
    final language =
        await _preferences.getString(_languageKey);

    final theme =
        await _preferences.getString(_themeKey);

    if (language == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }

    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
  }

  Future<void> setLanguage(
    String languageCode,
  ) async {
    if (languageCode != 'en' &&
        languageCode != 'ar') {
      return;
    }

    _locale = Locale(languageCode);

    await _preferences.setString(
      _languageKey,
      languageCode,
    );

    notifyListeners();
  }

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    _themeMode = mode;

    await _preferences.setString(
      _themeKey,
      mode == ThemeMode.dark
          ? 'dark'
          : 'light',
    );

    notifyListeners();
  }
}