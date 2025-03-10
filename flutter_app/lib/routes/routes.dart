import 'package:ecosphere/views/index_view.dart';
import 'package:flutter/material.dart';
import '../views/add_post/add_post.dart';
import '../views/walkthrough/walkthrough_1.dart';
import '../views/walkthrough/walkthrough_2.dart';
import '../views/walkthrough/walkthrough_3.dart';
import '../views/auth/login.dart';
import '../views/auth/signup.dart';
import '../views/auth/signup_success.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => Walkthrough1(),
    '/walkthrough2': (context) => Walkthrough2(),
    '/walkthrough3': (context) => Walkthrough3(),
    '/login': (context) => Login(),
    '/signup': (context) => Signup(),
    '/signup-success': (context) => SignupSuccess(),
    '/index': (context) => IndexScreen(),
    '/add_post': (context) => AddPost(),
  };
}
