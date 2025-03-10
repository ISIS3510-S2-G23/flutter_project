import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> signup(
      {required String username,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(username);

      await FirebaseFirestore.instance
          .collection('users')
          .doc('user-$email')
          .set({
        'username': username,
        'email': email,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);

      Navigator.pushReplacementNamed(context, '/signup-success');
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';
      if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      }
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<void> login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      DocumentSnapshot? userDoc;
      for (var doc in querySnapshot.docs) {
        if (doc['email'] == email) {
          userDoc = doc;
          break;
        }
      }

      if (userDoc != null) {
        String username = userDoc.get('username');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        Navigator.pushReplacementNamed(context, '/index');
      } else {
        throw Exception('User not found');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';
      if (e.code == 'user-not-found') {
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for this user.';
      }
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, '/login');
  }

  void googleSignIn({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      String? username = userCredential.user?.displayName;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username ?? '');

      Navigator.pushReplacementNamed(context, '/index');
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }
}
