import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';
import 'package:natural_disaster_app/constant/enumtype.dart';
import 'package:provider/provider.dart';
import 'access.dart';

import 'connection_fail.dart';
import 'home.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = MultipleProvider.of(context).auth;
    auth.currentUser().then((userId) {
      setState(() {
        _authStatus =
            (userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn);
      });
    }).catchError((e) {
      print('User not authenticated! yet');
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _signedIn() {
    setState(() {
      _authStatus = AuthStatus.signedIn;
    });
    print('User Sign in');
  }

  void _signedOut() {
    setState(() {
      _authStatus = AuthStatus.notSignedIn;
    });
    print('User Sign out');
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        {
          return (Provider.of<InternetConnectionStatus>(context) ==
              InternetConnectionStatus.disconnected)
              ? ConnectionDown()
              : AccessScreen(onSignedIn: _signedIn);
        }
      case AuthStatus.signedIn:
        {
          return (Provider.of<InternetConnectionStatus>(context) ==
              InternetConnectionStatus.disconnected)
              ? ConnectionDown()
              : HomeScreen(onSignedOut: _signedOut);
        }
    }
  }
}
