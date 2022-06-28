import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';
import 'package:natural_disaster_app/constant/enumtype.dart';
import 'package:natural_disaster_app/view/segnalation.dart';
import 'package:natural_disaster_app/viewmodel/listviewmodelimage.dart';
import 'package:natural_disaster_app/widgets/list_image.dart';
import 'package:natural_disaster_app/widgets/navigator_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/google_map.dart';
import 'connection_fail.dart';
import 'loading.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({required this.onSignedOut});

  final VoidCallback onSignedOut;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;

  /** VARIABLE **/
  final formKeyHome = new GlobalKey<FormState>();
  Status _Status = Status.list;

  String name = "";
  String email = "";
  late Role _role;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setDataUser();
    super.didChangeDependencies();
  }

  /** SIGN OUT**/
  void _signOut(BuildContext context) async {
    try {
      var auth = MultipleProvider.of(context).auth;
      await auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print('error');
    }
  }

  /** MOVE TO MAPS/LIST **/
  void moveToMaps() {
    setState(() {
      _Status = Status.maps;
    });
  }

  void moveToList() {
    setState(() {
      _Status = Status.list;
    });
  }

  /** RETRIEVE DATA USER **/
  void setDataUser() async {
    setState(() => loading = true);
    var db = MultipleProvider.of(context).dbRealtime;
    var auth = MultipleProvider.of(context).auth;
    await db.getUser(auth.getUserUid()).then((userData) {
      if (userData != null) {
        setState(() => loading = false);
        name = userData["username"];
        email = userData["email"];
        if (userData["role"] == "utente") {
          _role = Role.utente;
          print("ACCESSO DA UTENTE");
        } else {
          _role = Role.admin;
          print("ACCESSO DA ADMIN");
        }
      }
    });
  }

  /** WIDGET **/
  void showNavigator() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return NavigatorDrawer(
            name: name,
            email: email,
            role: _role,
            onSignedOut: widget.onSignedOut,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return loading
            ? Loading()
            : ChangeNotifierProvider<ListViewModelImage>(
                create: (_) => ListViewModelImage(role: _role),
                child: Scaffold(
                  body: buildView(),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: _role == Role.utente
                      ? FloatingActinButtonUser()
                      : FloatingActinButtonAdmin(),
                  bottomNavigationBar: _role == Role.utente
                      ? BottomAppBarButtonUser()
                      : BottomAppBarButtonAdmin(),
                ),
              );
  }

  Widget buildView() {
    if (_Status == Status.list) {
      return ListImagesScreen(role: _role);
    } else {
      return GoogleMapScreen();
      // );
    }
  }

  Widget FloatingActinButtonUser() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => SegnalationFromScreen()));
      },
      tooltip: 'Add Disasters',
      child: Icon(Icons.add),
      backgroundColor: Color(0xffF37335),
      splashColor: Colors.white,
    );
  }

  Widget FloatingActinButtonAdmin() {
    return FloatingActionButton(
      onPressed: () => _Status == Status.list ? moveToMaps() : moveToList(),
      tooltip: 'Switch Screen',
      child: Icon(_Status == Status.list ? Icons.map : Icons.list),
      backgroundColor: Color(0xffF37335),
      splashColor: Colors.white,
    );
  }

  Widget BottomAppBarButtonAdmin() {
    return BottomAppBar(
      color: Color(0xffF37335),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              child: Icon(Icons.account_circle),
              onPressed: showNavigator,
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
            ),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }

  Widget BottomAppBarButtonUser() {
    return BottomAppBar(
      color: Color(0xffF37335),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              child: Icon(Icons.account_circle),
              onPressed: showNavigator,
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
            ),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
