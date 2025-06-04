// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_trabalho.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalTrabalhoAdapter extends TypeAdapter<LocalTrabalho> {
  @override
  final int typeId = 0;

  @override
  LocalTrabalho read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalTrabalho(
      id: fields[0] as String,
      nome: fields[1] as String,
      corHex: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTrabalho obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.corHex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTrabalhoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
