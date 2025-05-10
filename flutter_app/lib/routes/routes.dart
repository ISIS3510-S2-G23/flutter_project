import 'package:ecosphere/views-viewmodels/index_view.dart';
import 'package:flutter/material.dart';
import '../views-viewmodels/add_post/add_post.dart';
import '../views-viewmodels/walkthrough/walkthrough_1.dart';
import '../views-viewmodels/walkthrough/walkthrough_2.dart';
import '../views-viewmodels/walkthrough/walkthrough_3.dart';
import '../views-viewmodels/auth/login.dart';
import '../views-viewmodels/auth/signup.dart';
import '../views-viewmodels/auth/signup_success.dart';
import '../views-viewmodels/home/splash.dart';

import 'package:ecosphere/views-viewmodels/account/edit_account.dart';
import 'package:ecosphere/views-viewmodels/account/setting_privacy.dart';
import 'package:ecosphere/views-viewmodels/account/help.dart';
import 'package:ecosphere/views-viewmodels/account/log_out.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashScreen(),
    '/walkthrough1': (context) => Walkthrough1(),
    '/walkthrough2': (context) => Walkthrough2(),
    '/walkthrough3': (context) => Walkthrough3(),
    '/login': (context) => Login(),
    '/signup': (context) => Signup(),
    '/signup-success': (context) => SignupSuccess(),
    '/index': (context) => IndexScreen(),
    '/add_post': (context) => AddPost(),
    '/edit-account': (context) => const EditAccount(),
    '/settings': (context) => const Settings(),
    '/help': (context) => const Help(),
    '/logout': (context) => const LogoutScreen(),
  };
}
