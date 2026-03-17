import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleAdapter extends TypeAdapter<Locale> {
  @override
  Locale read(BinaryReader reader) {
    return Locale(reader.readString(), reader.read());
  }

  @override
  void write(BinaryWriter writer, Locale obj) {
    writer.writeString(obj.languageCode);
    writer.write(obj.countryCode);
  }

  @override
  int get typeId => 1;
}
