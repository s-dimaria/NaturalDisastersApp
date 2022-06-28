import 'package:flutter/material.dart';
import 'package:natural_disaster_app/service/firebase/dbfirebase_storage.dart';
import 'package:natural_disaster_app/service/firebase/dbfirebase_realtime.dart';

import 'firebase/firebase_auth.dart';

class MultipleProvider extends InheritedWidget {
  MultipleProvider(
      {Key? key,
      required Widget child,
      required this.auth,
      required this.dbStorage,
      required this.dbRealtime})
      : super(key: key, child: child);

  final BaseAuth auth;
  final BasedbFirebaseStorage dbStorage;
  final BasedbFirebaseRealtime dbRealtime;

  /*When this widget is rebuilt, sometimes we need to rebuild the widgets
   *that inherit from this widget but sometimes we do not.*/
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static MultipleProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MultipleProvider>()
        as MultipleProvider;
  }
}
