import 'package:cloud_firestore/cloud_firestore.dart';

class LocationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getLocations() async {
    try {
      return _firestore.collection('locations').get();
    } catch (e) {
      rethrow;
    }
  }
}
