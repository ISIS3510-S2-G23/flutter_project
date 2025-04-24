import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class MapViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  List<Marker> _markers = [];
  bool _loaded = false;

  List<Marker> get markers => _markers;
  bool get isLoaded => _loaded;

  Future<void> loadMarkers() async {
    if (_loaded) return;

    _markers = await _locationService.fetchMapMarkers();
    _loaded = true;
    notifyListeners();
  }
}
