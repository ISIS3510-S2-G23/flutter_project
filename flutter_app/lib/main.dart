import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecosphere/firebase_options.dart';
import 'package:ecosphere/models/classification_entry.dart';
import 'package:ecosphere/routes/routes.dart';
import 'package:ecosphere/services/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    listenForConnectivityChanges();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicializa Hive
    await Hive.initFlutter();

    // Registra el adapter del modelo de clasificación
    Hive.registerAdapter(ClassificationEntryAdapter());

    // Abre todos los boxes necesarios
    await Hive.openBox('posts');
    await Hive.openBox('postsQueue');
    await Hive.openBox<ClassificationEntry>('classifications');

    if (kDebugMode) {
      print("Firebase inicializado correctamente");
    }

    // Probar conexión con Firebase Auth
    await testFirebaseAuthConnection();

    // Solicitar permisos de ubicación
    await requestLocationPermission();
  } catch (e) {
    if (kDebugMode) {
      print("Error al inicializar Firebase: $e");
    }
  }

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (errorDetails, stack) {
    FirebaseCrashlytics.instance.recordError(errorDetails, stack);
    return true;
  };

  CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
    cloudName: 'dhrkcqd33',
    apiKey: '537811732293891',
  );

  // Obtener la API key de ChatGPT
  final chatGptApiKey = dotenv.env['KEY_ECOSPHERE'] ?? '';

  // Escuchar el Stream de conectividad
  connectivityStream().listen((isConnected) {
    if (!isConnected) {
      showConnectivityToast();
    }
  });

  runApp(MyApp(chatGptApiKey: chatGptApiKey));
}

Future<void> testFirebaseAuthConnection() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    if (kDebugMode) {
      print("Firebase Auth funciona correctamente.");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error en Firebase Auth: $e");
    }
  }
}

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    if (kDebugMode) {
      print("Los permisos de ubicación están denegados permanentemente.");
    }
  } else {
    if (kDebugMode) {
      print("Permiso de ubicación concedido.");
    }
  }
}

class MyApp extends StatelessWidget {
  final String chatGptApiKey;

  const MyApp({super.key, required this.chatGptApiKey});

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

void listenForConnectivityChanges() {
  Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      await processPendingPosts();
    }
  });
}

Future<void> processPendingPosts() async {
  try {
    bool isConnected = await hasInternetConnection();

    if (isConnected) {
      var box = Hive.box('postsQueue');
      List<dynamic> pendingPosts = box.values.toList();

      for (var post in pendingPosts) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(
                'post-${post['user']}-${DateTime.now().millisecondsSinceEpoch}')
            .set({
          'title': post['title'],
          'text': post['text'],
          'tags': post['tags'],
          'user': post['user'],
          'timestamp': FieldValue.serverTimestamp(),
          'upvotes': 0,
          'comments': post['comments']
        });
      }

      await box.clear();
    }
  } catch (e) {
    rethrow;
  }
}

Future<bool> hasInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;
}
