import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<List<Marker>> fetchMapMarkers() async {
    List<Marker> markers = [];

    final snapshot =
        await FirebaseFirestore.instance.collection('locations').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      if (data.containsKey('location') && data.containsKey('name')) {
        final name = data['name'];
        final lat = data['location'].latitude;
        final lng = data['location'].longitude;

        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
          ),
        );
      }
    }

    return markers;
  }
}
