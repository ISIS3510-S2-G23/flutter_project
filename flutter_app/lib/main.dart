import 'package:ecosphere/firebase_options.dart';
import 'package:ecosphere/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inicializado correctamente");

    // Probar conexión con Firebase Auth
    await testFirebaseAuthConnection();

    // Solicitar permisos de ubicación
    await requestLocationPermission();
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (errorDetails, stack) {
    FirebaseCrashlytics.instance.recordError(errorDetails, stack);
    return true;
  };

  CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
      cloudName: 'dhrkcqd33', apiKey: '537811732293891');

  runApp(MyApp());
}

/// ✅ **Función para probar conexión con Firebase Authentication**
Future<void> testFirebaseAuthConnection() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print("Firebase Auth funciona correctamente.");
  } catch (e) {
    print("Error en Firebase Auth: $e");
  }
}

/// ✅ **Función para solicitar permisos de ubicación**
Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    print("Los permisos de ubicación están denegados permanentemente.");
  } else {
    print("Permiso de ubicación concedido.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recycling App',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF49447E,
          <int, Color>{
            50: Color(0xFFE8E7F0),
            100: Color(0xFFC5C3DA),
            200: Color(0xFF9E9BC1),
            300: Color(0xFF7773A8),
            400: Color(0xFF59558F),
            500: Color(0xFF49447E),
            600: Color(0xFF413C76),
            700: Color(0xFF38326B),
            800: Color(0xFF302961),
            900: Color(0xFF211A4E),
          },
        ),
      ),
      initialRoute: '/',
      routes: Routes.routes,
    );
  }
}
