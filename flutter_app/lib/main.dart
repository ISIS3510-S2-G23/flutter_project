import 'package:ecosphere/routes/routes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
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
