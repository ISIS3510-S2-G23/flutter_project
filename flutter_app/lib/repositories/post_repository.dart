import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../database/post_database.dart'; // database local

class PostsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PostDatabase _database = PostDatabase.instance;

  // Obtener todos los posts (filtrados por tag o no)
  Stream<List<PostModel>> getPosts({String? tag}) async* {
    try {
      // Verificar conectividad
      var connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        // Con internet: obtener de Firestore y cachear
        Stream<QuerySnapshot> postsStream;
        
        if (tag != null) {
          postsStream = _firestore
              .collection('posts')
              .where('tags', arrayContains: tag)
              .snapshots();
        } else {
          postsStream = _firestore.collection('posts').snapshots();
        }

        await for (var snapshot in postsStream) {
          // Convertir a lista de PostModel
          final posts = snapshot.docs
              .map((doc) => PostModel.fromFirestore(doc))
              .toList();
          
          // Cachear posts para uso offline
          _cachePosts(posts); 
          
          // Emitir posts
          yield posts;
        }
      } else {
        // Sin internet: obtener de la base de datos local
        List<PostModel> localPosts;
        
        if (tag != null) {
          localPosts = await _database.getPostsByTag(tag);
        } else {
          localPosts = await _database.getPosts();
        }
        
        yield localPosts;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en posts_repository: $e');
      }
      // En caso de error, intentar leer de la base local
      try {
        List<PostModel> localPosts;
        
        if (tag != null) {
          localPosts = await _database.getPostsByTag(tag);
        } else {
          localPosts = await _database.getPosts();
        }
        
        yield localPosts;
      } catch (dbError) {
        // Si falla todo, devolver lista vacía
        yield [];
      }
    }
  }

  // Método para cachear los posts en la base de datos local
  Future<void> _cachePosts(List<PostModel> posts) async {
    try {
      // Guardar solo los 15 primeros posts
      final topPosts = posts.take(10).toList();
      await _database.savePosts(topPosts);
      if (kDebugMode) {
        print('Caché actualizado: ${topPosts.length} posts');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cachear posts: $e');
      }
    }
  }
}