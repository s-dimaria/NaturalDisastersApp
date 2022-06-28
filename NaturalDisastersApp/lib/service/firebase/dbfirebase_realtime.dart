import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:natural_disaster_app/service/firebase/firebase_auth.dart';
import 'package:natural_disaster_app/constant/constant.dart';
import 'package:natural_disaster_app/model/image.dart';
import 'package:natural_disaster_app/model/user.dart';

abstract class BasedbFirebaseRealtime {
  Future<void> createUser(ModelUser _user);
  Future<Map<dynamic, dynamic>> getUser(String uid);

  Future<void> putImage(ModelImage _image);
  Future<void> removeImage(String _userId, String urlImage);
  Future<void> editImage(String _userId, String _imageId, String state);

  Stream<Event> getStreamImage();
  Stream<Event> getStreamImageUser();
}

class DbFirebaseRealtime extends BasedbFirebaseRealtime {
  final _dbDate = FirebaseDatabase(databaseURL: Constants.DB_URL)
      .reference()
      .child(Constants.DB_DATA);
  BaseAuth auth = Auth();

  /** POST METHOD **/
  @override
  Future<void> createUser(ModelUser _user) async {
    try {
      await _dbDate
          .child(Constants.DB_USER)
          .child(auth.getUserUid())
          .set(_user.toJson());
      print('Registered user: ' + auth.getUserUid());
    } catch (e) {
      print('error');
    }
  }

  /** POST METHOD **/
  @override
  Future<void> putImage(ModelImage _image) async {
    try {
      var r = Random();
      print(_image.urlImage);
      await _dbDate
          .child(Constants.DB_IMAGES)
          .child(_image.userId)
          .child("-" +
              List.generate(
                      19,
                      (index) =>
                          Constants.CHARS[r.nextInt(Constants.CHARS.length)])
                  .join())
          .set(_image.toJson());
      print('Image Saved: ' + _image.state);
    } catch (e) {
      print(e);
    }
  }

  /** GET METHOD **/
  @override
  Future<Map<dynamic, dynamic>> getUser(String uid) async {
    print("RECUPERO VALORI DAL DB UsersData");

    return await _dbDate
        .child(Constants.DB_USER)
        .child(uid)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      return values;
    });
  }

  /** PUT METHOD **/
  Future<void> editImage(String _userId, String _imageId, String state) async {
    final test = _dbDate
        .child(Constants.DB_IMAGES)
        .child(_userId)
        .child(_imageId)
        .update({"state": state});
  }

  /** DELETE METHOD **/
  Future<void> removeImage(String _userId, String urlImage) async {
    await _dbDate
        .child(Constants.DB_IMAGES)
        .child(_userId)
        .once()
        .then((value) {
      Map nextImage = value.value;
      nextImage.forEach((key, value) {
        if (value['urlImage'] == urlImage) {
          _dbDate.child(Constants.DB_IMAGES).child(_userId).child(key).remove();
        }
      });
    });
  }

  @override
  Stream<Event> getStreamImage() {
    return _dbDate.child(Constants.DB_IMAGES).onValue;
  }

  @override
  Stream<Event> getStreamImageUser() {
    return _dbDate.child(Constants.DB_IMAGES).child(auth.getUserUid()).onValue;
  }
}
