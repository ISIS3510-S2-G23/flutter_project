import 'package:hive/hive.dart';

part 'classification_entry.g.dart';

@HiveType(typeId: 1)
class ClassificationEntry {
  @HiveField(0)
  final String hash;

  @HiveField(1)
  final String classification;

  @HiveField(2)
  final DateTime date;

  ClassificationEntry({
    required this.hash,
    required this.classification,
    required this.date,
  });
}
