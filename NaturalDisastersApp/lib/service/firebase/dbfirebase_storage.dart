import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';

abstract class BasedbFirebaseStorage {
  Future<String> putPhoto(BuildContext context, File _imageFile);
  Future<void> removePhoto(String url);
}

class DbFirebaseStorage extends BasedbFirebaseStorage {
  final fbStorageRef = FirebaseStorage.instance;

  /** POST METHOD **/
  @override
  Future<String> putPhoto(BuildContext context, File _imageFile) async {
    var auth = MultipleProvider.of(context).auth;

    String userId = await auth.currentUser();
    String fileName = basename(_imageFile.path);
    String _downloadUrl = "";

    final fbRef = fbStorageRef.ref().child('$userId').child('$fileName');

    try {
      UploadTask uploadTask = fbRef.putFile(_imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      _downloadUrl =
          await fbRef.getDownloadURL().then((value) => value).catchError((e) {
        print(e.message.toString() + ' Add photo in storage.');
      });
      return _downloadUrl;
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(
          msg: "File upload failed. Incorrect file type (only .jpg or .png) or description, retry.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 10,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    return _downloadUrl;
  }

  /** DELETE **/
  @override
  Future<void> removePhoto(String urlImage) async {
    // remove to storage
    Reference photoRef = fbStorageRef.refFromURL(urlImage);
    photoRef.delete().whenComplete(() => print("Successfull removed"));
  }
}
