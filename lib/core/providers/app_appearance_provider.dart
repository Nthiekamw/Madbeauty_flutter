import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../constants/strings/discovery/disc_appearance.dart';
import '../../services/storage/local_cache_service.dart';

enum AppLanguage { french, english }

class AppAppearanceState {
  const AppAppearanceState({
    required this.themeMode,
    required this.language,
  });

  final ThemeMode themeMode;
  final AppLanguage language;

  Locale get locale => switch (language) {
        AppLanguage.french => const Locale('fr', 'FR'),
        AppLanguage.english => const Locale('en', 'US'),
      };

  AppAppearanceState copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
  }) {
    return AppAppearanceState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
}

final appAppearanceProvider =
    NotifierProvider<AppAppearanceNotifier, AppAppearanceState>(
  AppAppearanceNotifier.new,
);

class AppAppearanceNotifier extends Notifier<AppAppearanceState> {
  @override
  AppAppearanceState build() {
    final cache = LocalCacheService.instance;
    return AppAppearanceState(
      themeMode: _themeFromStorage(cache.appThemeMode),
      language: _languageFromStorage(cache.appLanguageCode),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    await LocalCacheService.instance.setAppThemeMode(_themeToStorage(mode));
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == state.language) return;
    await LocalCacheService.instance.setAppLanguageCode(
      _languageToStorage(language),
    );
    await initializeDateFormatting(
      language == AppLanguage.french ? 'fr_FR' : 'en_US',
    );
    state = state.copyWith(language: language);
  }

  static ThemeMode _themeFromStorage(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _themeToStorage(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  static AppLanguage _languageFromStorage(String? raw) {
    return raw == 'en' ? AppLanguage.english : AppLanguage.french;
  }

  static String _languageToStorage(AppLanguage language) {
    return language == AppLanguage.english ? 'en' : 'fr';
  }
}

String themeModeLabel(ThemeMode mode, Locale locale) {
  return switch (mode) {
    ThemeMode.light => DiscAppearance.themeLight(locale),
    ThemeMode.dark => DiscAppearance.themeDark(locale),
    ThemeMode.system => DiscAppearance.themeSystem(locale),
  };
}

String languageLabel(AppLanguage language, Locale locale) {
  return switch (language) {
    AppLanguage.french => DiscAppearance.languageFrench(locale),
    AppLanguage.english => DiscAppearance.languageEnglish(locale),
  };
}
