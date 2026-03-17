import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  ThemeMode read(BinaryReader reader) {
    return ThemeMode.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeInt(obj.index);
  }

  @override
  int get typeId => 2;
}
