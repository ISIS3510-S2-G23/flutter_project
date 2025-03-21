import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getChallenges() async {
    try {
      return _firestore.collection('challenges').snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUsersChallenges(
      challengeId, user) async {
    try {
      return FirebaseFirestore.instance
          .collection('users-challenges')
          .doc('$challengeId-$user')
          .get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCompletedChallenge(challengeId, user) async {
    try {
      FirebaseFirestore.instance
          .collection('users-challenges')
          .doc('$challengeId-$user')
          .set({
        'completed': true,
        'progress': 1.0,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}
