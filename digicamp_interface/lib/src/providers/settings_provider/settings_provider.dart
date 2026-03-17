import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/config/theme.dart';

part 'settings_provider.g.dart';

//
@HiveType(typeId: 4)
class SettingsProvider extends ChangeNotifier with HiveObjectMixin {
  /// Map key to get access of current object
  static const String _key = "settingsData";

  @HiveField(1)
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeConfig.lightTheme;

  ThemeData get darkTheme => ThemeConfig.darkTheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  static Future<SettingsProvider> instance() async {
    final settingsBox = await Hive.openBox<SettingsProvider>(kSettingBox);
    final settingsData = settingsBox.get(_key);
    if (settingsData == null) {
      await settingsBox.put(_key, SettingsProvider());
    }
    return settingsBox.get(_key)!;
  }

  void changeTheme([ThemeMode? mode]) {
    if (mode != null && _themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      save();
      return;
    }
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
    save();
  }
}
