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
      notetitle: fields[1] as String,
      textnote: fields[2] as String?,
      checklist: (fields[3] as List?)?.cast<String>(),
      isRead: fields[4] as bool,
      isDelete: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.destination)
      ..writeByte(1)
      ..write(obj.notetitle)
      ..writeByte(2)
      ..write(obj.textnote)
      ..writeByte(3)
      ..write(obj.checklist)
      ..writeByte(4)
      ..write(obj.isRead)
      ..writeByte(5)
      ..write(obj.isDelete);
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
