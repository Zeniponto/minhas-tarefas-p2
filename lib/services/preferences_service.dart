import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  PreferencesService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;
  bool _temaEscuro = false;

  bool get temaEscuro => _temaEscuro;
  ThemeMode get themeMode => _temaEscuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> carregar() async {
    _temaEscuro = await _preferences.getBool('tema_escuro') ?? false;
    notifyListeners();
  }

  Future<void> alterarTema(bool escuro) async {
    await _preferences.setBool('tema_escuro', escuro);
    _temaEscuro = escuro;
    notifyListeners();
  }
}
