// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsProviderAdapter extends TypeAdapter<SettingsProvider> {
  @override
  final int typeId = 4;

  @override
  SettingsProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsProvider().._themeMode = fields[1] as ThemeMode;
  }

  @override
  void write(BinaryWriter writer, SettingsProvider obj) {
    writer
      ..writeByte(1)
      ..writeByte(1)
      ..write(obj._themeMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
