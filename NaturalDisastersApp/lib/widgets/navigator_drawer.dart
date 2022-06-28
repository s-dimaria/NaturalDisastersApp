import 'package:flutter/material.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';
import 'package:natural_disaster_app/constant/constant.dart';
import 'package:natural_disaster_app/constant/enumtype.dart';
import 'package:natural_disaster_app/view/segnalation.dart';

class NavigatorDrawer extends StatelessWidget {
  NavigatorDrawer({
    required this.name,
    required this.email,
    required this.role,
    required this.onSignedOut,
  });

  final VoidCallback onSignedOut;

  String name;
  String email;
  Role role;
  final urlImage = Constants.IMAGEUSER;

  void _signOut(BuildContext context) async {
    try {
      var auth = MultipleProvider.of(context).auth;
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print('error');
    }
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required Role role,
  }) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(width: 5),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                Text(
                  "Role: " + (role == Role.admin ? "admin" : "user"),
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return role == Role.utente
        ? _buildDrawerUser(context)
        : _buildDrawerAdmin(context);
  }

  Widget _buildDrawerUser(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color(0xffF37335),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: <Widget>[
            buildHeader(
              urlImage: urlImage,
              name: name,
              email: email,
              role: role,
            ),
            buildMenuItem(
              text: 'Add Segnalation',
              icon: Icons.add,
              onClicked: () => selectedItem(context, 0),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white),
            const SizedBox(height: 24),
            buildMenuItem(
              text: 'Logout',
              icon: Icons.logout,
              onClicked: () => selectedItem(context, 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerAdmin(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color(0xffF37335),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: <Widget>[
            buildHeader(
              urlImage: urlImage,
              name: name,
              email: email,
              role: role,
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white),
            const SizedBox(height: 24),
            buildMenuItem(
              text: 'Logout',
              icon: Icons.logout,
              onClicked: () => selectedItem(context, 9),
            ),
          ],
        ),
      ),
    );
  }

  void selectedItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SegnalationFromScreen()));
        break;

      case 9:
        Navigator.pop(context);
        _signOut(context);
        break;
    }
  }
}
