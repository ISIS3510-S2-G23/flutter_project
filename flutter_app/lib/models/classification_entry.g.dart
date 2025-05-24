// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classification_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassificationEntryAdapter extends TypeAdapter<ClassificationEntry> {
  @override
  final int typeId = 1;

  @override
  ClassificationEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassificationEntry(
      hash: fields[0] as String,
      classification: fields[1] as String,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ClassificationEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.hash)
      ..writeByte(1)
      ..write(obj.classification)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
