// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plantao.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantaoAdapter extends TypeAdapter<Plantao> {
  @override
  final int typeId = 1;

  @override
  Plantao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plantao(
      id: fields[0] as String,
      localTrabalhoId: fields[1] as String,
      valor: fields[2] as double,
      dataPagamento: fields[3] as DateTime?,
      pago: fields[4] as bool,
      dataHoraInicio: fields[5] as DateTime,
      dataHoraFim: fields[6] as DateTime,
      comentarios: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Plantao obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.localTrabalhoId)
      ..writeByte(2)
      ..write(obj.valor)
      ..writeByte(3)
      ..write(obj.dataPagamento)
      ..writeByte(4)
      ..write(obj.pago)
      ..writeByte(5)
      ..write(obj.dataHoraInicio)
      ..writeByte(6)
      ..write(obj.dataHoraFim)
      ..writeByte(7)
      ..write(obj.comentarios);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
