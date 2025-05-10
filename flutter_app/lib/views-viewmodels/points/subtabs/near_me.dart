// ignore_for_file: unused_field

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter/material.dart';
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
  bool _isConnected = true; // Estado de conectividad
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _getCurrentLocation();
    //_fetchRecyclingCenters();
    Future.microtask(() {
      final viewModel = context.read<MapViewModel>();
      viewModel.loadMarkers().then((_) {
        if (kDebugMode) {
          print("✅ TEST: Se cargaron ${viewModel.markers.length} marcadores:");
        }
        for (var m in viewModel.markers) {
          if (kDebugMode) {
            print(
                "- ${m.markerId.value} | ${m.position.latitude}, ${m.position.longitude}");
          }
        }
      }).catchError((e) {
        if (kDebugMode) {
          print("❌ Error en NearMe ViewModel: $e");
        }
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _checkConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });

      if (!_isConnected) {
        Fluttertoast.showToast(
          msg:
              "It is not possible to load Google maps. Please check your connection.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.black,
        );
      }
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
      body: !_isConnected
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "There is no internet connection available... Please refresh the page when connected.",
                    style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                  ),
                ],
              ),
            )
          : _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: {
                    if (_currentPosition != null)
                      Marker(
                        markerId: MarkerId("current_location"),
                        position: _currentPosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        infoWindow: InfoWindow(title: "Your Location"),
                      ),
                  },
                ),
    );
  }
}
//
