import 'package:flutter/widgets.dart';

/// Idiomas soportados por la app.
enum AppLanguage {
  spanish('es'),
  english('en');

  const AppLanguage(this.code);
  final String code;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    if (code == 'en') return AppLanguage.english;
    return AppLanguage.spanish;
  }
}
