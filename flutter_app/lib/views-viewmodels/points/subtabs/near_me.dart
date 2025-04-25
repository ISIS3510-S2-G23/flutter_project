// ignore_for_file: unused_field

import 'package:ecosphere/repositories/locations_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ecosphere/views-viewmodels/map_viewmodel.dart';

class NearMe extends StatefulWidget {
  const NearMe({super.key});

  @override
  _NearMeState createState() => _NearMeState();
}

class _NearMeState extends State<NearMe> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  //Set<Marker> _markers = {};
  //final LocationsRepository _locationsRepository = LocationsRepository();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    //_fetchRecyclingCenters();
    Future.microtask(() {
      final viewModel = context.read<MapViewModel>();
      viewModel.loadMarkers().then((_) {
        print("✅ TEST: Se cargaron ${viewModel.markers.length} marcadores:");
        for (var m in viewModel.markers) {
          print(
              "- ${m.markerId.value} | ${m.position.latitude}, ${m.position.longitude}");
        }
      }).catchError((e) {
        print("❌ Error en NearMe ViewModel: $e");
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  //Future<void> _fetchRecyclingCenters() async {
  //_locationsRepository.getLocations().then((query) {
  //Set<Marker> newMarkers = {};
  //for (var doc in query.docs) {
  //var data = doc.data();
  //GeoPoint location = data['location'];
  //newMarkers.add(
  //Marker(
  //markerId: MarkerId(doc.id),
  //position: LatLng(location.latitude, location.longitude),
  //infoWindow: InfoWindow(title: data['name']),
  //),
  //);
  //}
  //setState(() {
  //_markers = newMarkers;
  //});
  //});
  //}

  @override
  Widget build(BuildContext context) {
    final mapViewModel = context.watch<MapViewModel>();

    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                Marker(
                  markerId: const MarkerId("current_location"),
                  position: _currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  infoWindow: const InfoWindow(title: "Your Location"),
                ),
                ...mapViewModel.markers,
              },
            ),
    );
  }
}
