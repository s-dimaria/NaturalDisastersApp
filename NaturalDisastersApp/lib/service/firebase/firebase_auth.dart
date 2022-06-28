import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/** INTERFACE AUTH **/
abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<bool> sendPasswordResetEmail(String email);

  Future<String> currentUser();
  String getUserUid();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /* LOGIN */
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    UserCredential _userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      Fluttertoast.showToast(
          msg: e.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 7,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
    return _userCredential.user!.uid;
  }

  /* SIGN IN */
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      Fluttertoast.showToast(
          msg: e.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 7,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });

    return userCredential.user!.uid;
  }

  /* RESET PASSWORD */
  Future<bool> sendPasswordResetEmail(String email) async {
    bool ok = true;
    await firebaseAuth.sendPasswordResetEmail(email: email).catchError((e) {
      Fluttertoast.showToast(
          msg: e.message.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 7,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      ok = !ok;
    });
    print('Accept request change password!');
    return ok;
  }

  // Return a valid user uid
  Future<String> currentUser() async {
    return await firebaseAuth.currentUser!.uid;
  }

  String getUserUid() {
    return firebaseAuth.currentUser!.uid;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
