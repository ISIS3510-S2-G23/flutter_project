import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

class PostsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference<Map<String, dynamic>>> getDocByPostId(
      String postId) async {
    try {
      DocumentReference<Map<String, dynamic>> document =
          _firestore.collection('posts').doc(postId);
      return document;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      bool isConnected = await hasInternetConnection();

      if (isConnected) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('posts')
            .orderBy('upvotes', descending: true)
            .get();

        List<Map<String, dynamic>> posts = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        var box = Hive.box('posts');
        await box.put('cachedPosts', posts);

        return posts;
      } else {
        var box = Hive.box('posts');
        List<dynamic>? cachedPosts = box.get('cachedPosts');

        if (cachedPosts != null) {
          return List<Map<String, dynamic>>.from(cachedPosts);
        } else {
          throw Exception('No hay conexión y no hay datos en caché.');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFilteredPosts(
      String selectedChip) async {
    try {
      bool isConnected = await hasInternetConnection();

      if (isConnected) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
            .collection('posts')
            .where('tags', arrayContains: selectedChip)
            .orderBy('upvotes', descending: true)
            .get();

        List<Map<String, dynamic>> posts = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        var box = Hive.box('posts');
        await box.put('cachedFilteredPosts-$selectedChip', posts);

        return posts;
      } else {
        var box = Hive.box('posts');
        List<dynamic>? cachedPosts =
            box.get('cachedFilteredPosts-$selectedChip');

        if (cachedPosts != null) {
          return List<Map<String, dynamic>>.from(cachedPosts);
        } else {
          throw Exception('No hay conexión y no hay datos en caché.');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadPosts(String title, String text, List<String> tags,
      String user, List<String> comments) async {
    try {
      bool isConnected = await hasInternetConnection();

      if (isConnected) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc('post-$user-${DateTime.now().millisecondsSinceEpoch}')
            .set({
          'title': title,
          'text': text,
          'tags': tags,
          'user': user,
          'timestamp': FieldValue.serverTimestamp(),
          'upvotes': 0,
          'comments': comments
        });
      } else {
        var box = Hive.box('postsQueue');
        await box.add({
          'title': title,
          'text': text,
          'tags': tags,
          'user': user,
          'comments': comments,
          'timestamp': DateTime.now().toIso8601String(),
        });
        Fluttertoast.showToast(
          msg:
              "There is no internet connection. Your post will be uploaded when reconnected.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
