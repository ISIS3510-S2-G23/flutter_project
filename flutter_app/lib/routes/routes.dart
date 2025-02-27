import 'package:flutter/material.dart';
import '../screens/walkthrough/walkthrough_1.dart';
import '../screens/walkthrough/walkthrough_2.dart';
import '../screens/walkthrough/walkthrough_3.dart';
import '../screens/auth/login.dart';
import '../screens/auth/signup.dart';
import '../screens/home/home.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => Walkthrough1(),
    '/walkthrough2': (context) => Walkthrough2(),
    '/walkthrough3': (context) => Walkthrough3(),
    '/login': (context) => Login(),
    '/signup': (context) => Signup(),
    // '/home': (context) => Home(),
  };
}
