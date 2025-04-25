import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String text;
  final String user;
  final String asset;
  final int upvotes;
  final List<dynamic> upvotedBy;
  final List<String> tags;
  final Map<String, dynamic> comments;

  PostModel({
    required this.id,
    required this.title,
    required this.text,
    required this.user,
    this.asset = '',
    this.upvotes = 0,
    this.upvotedBy = const [],
    this.tags = const [],
    this.comments = const {},
  });

  // Convertir de Map a objeto PostModel
  factory PostModel.fromMap(Map<String, dynamic> map) {
    // Procesar los tags (pueden ser una lista o una cadena separada por comas)
    List<String> processTags() {
      if (map['tags'] is List) {
        return (map['tags'] as List).map((e) => e.toString()).toList();
      } else if (map['tags'] is String) {
        return (map['tags'] as String).split(', ');
      }
      return [];
    }

    return PostModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      user: map['user'] ?? '',
      asset: map['asset'] ?? '',
      upvotes: map['upvotes'] is int ? map['upvotes'] : 0,
      upvotedBy: map['upvotedBy'] is List ? map['upvotedBy'] : [],
      tags: processTags(),
      comments: (map['comments'] is Map) 
          ? Map<String, dynamic>.from(map['comments']) 
          : {},
    );
  }

  // Convertir de documento Firestore a PostModel
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Asegurar que el ID se incluye
    return PostModel.fromMap(data);
  }

  // Convertir el objeto a Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'user': user,
      'asset': asset,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy.join(','), // Convertir a string para SQLite
      'tags': tags.join(', '), // Guardar tags como string separado por comas
      'comments': comments.toString(), // Simplificar para SQLite
    };
  }

  // Convertir a Map JSON-friendly para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'user': user,
      'asset': asset,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'tags': tags,
      'comments': comments,
    };
  }
}