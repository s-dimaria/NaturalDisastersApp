import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import 'service/firebase/firebase_auth.dart';

import 'service/multiple_provider.dart';
import 'service/firebase/dbfirebase_storage.dart';
import 'service/firebase/dbfirebase_realtime.dart';
import 'view/root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultipleProvider(
      auth: Auth(),
      dbStorage: DbFirebaseStorage(),
      dbRealtime: DbFirebaseRealtime(),
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<InternetConnectionStatus>(
      create: (_) => InternetConnectionChecker().onStatusChange,
      initialData: InternetConnectionStatus.connected,
      child: MaterialApp(title: 'Login', home: RootPage()),
    );
  }
}
