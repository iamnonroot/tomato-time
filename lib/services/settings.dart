import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:pomodoro/core/storage.dart' as storage;

class SettingsProvider with ChangeNotifier {
  Locale _locale = Locale('en');
  Locale get locale => _locale;

  SettingsProvider() {
    this.loadLocale();
  }

  Future<void> loadLocale() async {
    String? code = await storage.getItem('locale');
    if (code == null) code = 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    await storage.setItem('locale', locale.languageCode);
    _locale = locale;
    notifyListeners();
  }
}
