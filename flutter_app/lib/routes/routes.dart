import 'package:flutter/material.dart';
import '../views/walkthrough/walkthrough_1.dart';
import '../views/walkthrough/walkthrough_2.dart';
import '../views/walkthrough/walkthrough_3.dart';
import '../views/auth/login.dart';
import '../views/auth/signup.dart';
import '../views/auth/signup_success.dart';
import '../views/home/home.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => Walkthrough1(),
    '/walkthrough2': (context) => Walkthrough2(),
    '/walkthrough3': (context) => Walkthrough3(),
    '/login': (context) => Login(),
    '/signup': (context) => Signup(),
    '/signup-success': (context) => SignupSuccess(),
    '/home': (context) => Home(),
  };
}
