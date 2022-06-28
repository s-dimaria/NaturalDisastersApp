import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:natural_disaster_app/model/image.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';
import 'package:natural_disaster_app/constant/enumtype.dart';
import 'package:natural_disaster_app/viewmodel/listviewmodelimage.dart';
import 'package:natural_disaster_app/viewmodel/viewmodelimage.dart';
import 'package:provider/provider.dart';

class ListImagesScreen extends StatefulWidget {
  ListImagesScreen({required this.role});

  Role role;

  @override
  _ListImagesScreenState createState() => _ListImagesScreenState();
}

class _ListImagesScreenState extends State<ListImagesScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                "Segnalations",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  color: Color(0xffF37335),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          // SizedBox(height: 15),
          widget.role == Role.utente
              ? _buildListImageUser()
              : _buildListImageAdmin()
        ],
      ),
    );
  }

  Widget _buildListImageUser() {
    return Consumer<ListViewModelImage>(builder: (context, model, child) {
      final listImage = <Card>[];
      model.images.forEach((element) {
        final imageTile = Card(
          elevation: 5.0,
          child: ListTile(
            leading: CircleAvatar(
                radius: 30, backgroundImage: NetworkImage(element.urlImage)),
            title: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                  ),
                  children: [
                    TextSpan(
                      text: element.emergencyType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' - '),
                    TextSpan(
                      text: element.street,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text: ', ' + (element.locality ?? "locality"),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ]),
            ),
            subtitle: RichText(
              text: TextSpan(
                  text: 'State:',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: ' ' + element.state,
                      style: TextStyle(
                        color: element.state == "Pendente"
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
                onSurface: Colors.black12,
              ),
              child: Icon(
                Icons.delete,
                color: Color(0xffF37335),
              ),
              onPressed: () => _showMyDialogDeleteImage(element.urlImage),
            ),
          ),
        );
        listImage.add(imageTile);
      });
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: listImage.length == 0 ? [] : listImage,
          ),
        ),
      );
    });
  }

  Widget _buildListImageAdmin() {
    return Consumer<ListViewModelImage>(builder: (context, model, child) {
      final listImage = <Card>[];
      model.mapImages.forEach((key, value) {
        ViewModelImage element =
            ViewModelImage(image: ModelImage.fromJson(value));
        final imageTile = Card(
          elevation: 5.0,
          child: ListTile(
            leading: CircleAvatar(
                radius: 30, backgroundImage: NetworkImage(element.urlImage)),
            title: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                  ),
                  children: [
                    TextSpan(
                      text: element.emergencyType.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' - '),
                    TextSpan(
                      text: element.street,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text: ', ' + (element.locality ?? "locality"),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ]),
            ),
            subtitle: RichText(
              text: TextSpan(
                  text: 'State:',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: ' ' + element.state,
                      style: TextStyle(
                        color: element.state == "Pendente"
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
            ),
            trailing: element.state == "Pendente"
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      shadowColor: Colors.transparent,
                      onSurface: Colors.black12,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Color(0xffF37335),
                    ),
                    onPressed: () =>
                        _showMyDialogEditImage(key, element.userId),
                  )
                : null,
          ),
        );
        listImage.add(imageTile);
      });
      return SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: listImage.length == 0 ? [] : listImage,
              )));
    });
  }

  Future<void> _showMyDialogDeleteImage(String urlImage) async {
    var dbStorage = MultipleProvider.of(context).dbStorage;
    var dbRealtime = MultipleProvider.of(context).dbRealtime;
    var auth = MultipleProvider.of(context).auth;

    String _userId = await auth.currentUser();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure to remove this segnalation?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ACCEPT',
                  style: TextStyle(
                    color: Colors.green,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                dbStorage.removePhoto(urlImage);
                dbRealtime.removeImage(_userId, urlImage);
              },
            ),
            TextButton(
              child: const Text('CANCEL',
                  style: TextStyle(
                    color: Colors.red,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialogEditImage(String imageId, String userId) async {
    var dbRealtime = MultipleProvider.of(context).dbRealtime;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit State To "Risolto"'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure to change state of this segnalation?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ACCEPT',
                  style: TextStyle(
                    color: Colors.green,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                dbRealtime.editImage(userId, imageId, "Risolto");
              },
            ),
            TextButton(
              child: const Text('CANCEL',
                  style: TextStyle(
                    color: Colors.red,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
