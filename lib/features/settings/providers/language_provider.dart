import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch2earn/core/constants/app_constants.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languageCodeKey) ?? 'en';
    state = Locale(languageCode);
  }
  
  Future<void> setLanguage(BuildContext context, Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageCodeKey, locale.languageCode);
    await context.setLocale(locale);
    state = locale;
  }
}

class Language {
  final String name;
  final String code;
  final String flag;

  const Language({
    required this.name,
    required this.code,
    required this.flag,
  });
}

final List<Language> supportedLanguages = [
  const Language(name: 'English', code: 'en', flag: '🇺🇸'),
  const Language(name: 'Türkçe', code: 'tr', flag: '🇹🇷'),
  const Language(name: 'Deutsch', code: 'de', flag: '🇩🇪'),
  const Language(name: 'Français', code: 'fr', flag: '🇫🇷'),
  const Language(name: 'Español', code: 'es', flag: '🇪🇸'),
  const Language(name: 'Italiano', code: 'it', flag: '🇮🇹'),
];
