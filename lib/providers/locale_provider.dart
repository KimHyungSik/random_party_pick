import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String localePreferenceKey = 'locale';

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences prefs;

  LocaleNotifier(this.prefs) : super(_loadLocale(prefs));

  static Locale _loadLocale(SharedPreferences prefs) {
    final String? localeString = prefs.getString(localePreferenceKey);
    if (localeString == null || localeString.isEmpty) {
      return const Locale('en'); // Default to English
    }
    return Locale(localeString);
  }

  Future<void> setLocale(Locale locale) async {
    await prefs.setString(localePreferenceKey, locale.languageCode);
    state = locale;
  }

  // Get all supported locales
  static List<Locale> get supportedLocales => [
        const Locale('en'), // English
        const Locale('ko'), // Korean
        const Locale('th'), // Thai
        const Locale('fr'), // French
        const Locale('de'), // German
        const Locale('es'), // Spanish
        const Locale('ja'), // Japanese
      ];
}

// Provider to access SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Provider for the current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});