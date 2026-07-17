import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'preferred_lang';
  static const _storage = FlutterSecureStorage();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
    Locale('te'),
  ];

  LocaleProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final code = await _storage.read(key: _key) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    await _storage.write(key: _key, value: locale.languageCode);
    try {
      await ApiClient.instance.put(
        '/auth/preferred-lang',
        data: {'lang': locale.languageCode},
      );
    } catch (_) {
      // Best-effort — preference is already saved locally
    }
  }

  static String langLabel(String code) => switch (code) {
    'hi' => 'हिंदी',
    'ta' => 'தமிழ்',
    'te' => 'తెలుగు',
    _    => 'English',
  };
}
