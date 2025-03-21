import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getPosts() async {
    try {
      return FirebaseFirestore.instance
          .collection('posts')
          .orderBy('upvotes', descending: true)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getFilteredPosts(
      String selectedChip) async {
    try {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('tags', arrayContains: selectedChip)
          .orderBy('upvotes', descending: true)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadPosts(String title, String text, List<String> tags,
      String user, List<String> comments) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }
}
