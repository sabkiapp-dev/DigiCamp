// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthProviderAdapter extends TypeAdapter<AuthProvider> {
  @override
  final int typeId = 3;

  @override
  AuthProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthProvider()
      .._token = fields[0] as String?
      .._superUserToken = fields[1] as String?
      .._isSuperuser = fields[2] as bool
      .._userName = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, AuthProvider obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj._token)
      ..writeByte(1)
      ..write(obj._superUserToken)
      ..writeByte(2)
      ..write(obj._isSuperuser)
      ..writeByte(3)
      ..write(obj._userName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
