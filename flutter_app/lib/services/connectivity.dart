import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Stream<bool> connectivityStream() async* {
  final connectivity = Connectivity();

  var connectivityResult = await connectivity.checkConnectivity();
  yield connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;

  await for (var result in connectivity.onConnectivityChanged) {
    yield result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }
}

void showConnectivityToast() {
  Fluttertoast.showToast(
    msg: "No hay señal. Por favor, verifica tu conexión a Internet.",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 4,
    backgroundColor: Colors.blueGrey,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}
