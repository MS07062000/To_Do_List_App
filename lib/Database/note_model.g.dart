// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      destination: fields[0] as String,
      destinationCoordinates: fields[1] as String,
      notetitle: fields[2] as String,
      textnote: fields[3] == null ? '' : fields[3] as String?,
      checklist: fields[4] == null ? [] : (fields[4] as List?)?.cast<String>(),
      isDelete: fields[5] as bool,
      isNotified: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.destination)
      ..writeByte(1)
      ..write(obj.destinationCoordinates)
      ..writeByte(2)
      ..write(obj.notetitle)
      ..writeByte(3)
      ..write(obj.textnote)
      ..writeByte(4)
      ..write(obj.checklist)
      ..writeByte(5)
      ..write(obj.isDelete)
      ..writeByte(6)
      ..write(obj.isNotified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
