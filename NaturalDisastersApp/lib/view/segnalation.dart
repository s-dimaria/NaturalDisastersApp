import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';
import 'package:natural_disaster_app/constant/constant.dart';
import 'package:natural_disaster_app/model/image.dart';
import 'package:natural_disaster_app/service/position.dart';
import 'package:provider/provider.dart';

import 'connection_fail.dart';
import 'loading.dart';

class SegnalationFromScreen extends StatefulWidget {
  const SegnalationFromScreen({Key? key}) : super(key: key);

  @override
  _SegnalationFromScreenState createState() => _SegnalationFromScreenState();
}

class _SegnalationFromScreenState extends State<SegnalationFromScreen> {
  final formKeyData = new GlobalKey<FormState>();

  bool loading = false;
  String _description = "";
  String _type = Constants.listType[0];

  String _warningLevel = Constants.listEmergency[0];

  File? _imageFile;

  final picker = ImagePicker();

  /** METODI PER PRENDERE FOTO E CARICARE **/
  Future pickImageCamera() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 30).catchError((e) {
      print(e.message.toString());
    });
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future pickImageOnPhotos() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 30).catchError((e) {
      print(e.message.toString());
    });
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void uploadPhoto(BuildContext context, File file) async {
    var auth = MultipleProvider.of(context).auth;

    var _dbStorage = MultipleProvider.of(context).dbStorage;
    var _dbRealtime = MultipleProvider.of(context).dbRealtime;

    setState(() => loading = true);
    try {
      String _userId = await auth.currentUser();

      Position _position = await PositionUser.userPosition();

      String _urlImage = await _dbStorage.putPhoto(context, _imageFile!);

      PositionUser.GetAddressFromLatLong(_position).then((_placemark) {
        ModelImage _image = ModelImage(
            _userId,
            _urlImage,
            _description,
            _position.latitude,
            _position.longitude,
            _placemark.street,
            _placemark.locality,
            DateTime.now().toString(),
            _placemark.name,
            _type,
            int.parse(_warningLevel),
            "Pendente");

        _dbRealtime.putImage(_image);
        Navigator.pop(context);
      });
      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
      print("Error UPLOAD");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  /* VALIDATE FORM */
  bool validateAndSave() {
    final form = formKeyData.currentState;

    if (form!.validate() && _imageFile != null) {
      form.save();
      print('Upload IMAGE');
      return true;
    }
    return false;
  }

  /* SEND FORM */
  void validateAndSubmit() {
    if (validateAndSave()) {
      uploadPhoto(context, _imageFile!);
    } else {
      Fluttertoast.showToast(
          msg: "Incomplete form",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 7,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Provider.of<InternetConnectionStatus>(context) ==
            InternetConnectionStatus.disconnected)
        ? ConnectionDown()
        : loading
            ? Loading()
            : MaterialApp(
                title: 'Upload Segnalation',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: Scaffold(
                  body: Container(
                    child: Form(
                      key: formKeyData,
                      child: GestureDetector(
                        child: Stack(
                          children: <Widget>[
                            Container(
                                height: double.infinity,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xffF37335),
                                      Color(0xfff7b733),
                                    ],
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 80,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: buildForm(),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }

  /** WIDGET **/
  List<Widget> buildForm() {
    return [
      buildPhotoBtn(),
      SizedBox(height: 10),
      buildDescription(),
      SizedBox(height: 20),
      buildType(),
      SizedBox(height: 20),
      buildEmergency(),
      SizedBox(height: 20),
      buildUploadBtn(),
    ];
  }

  Widget buildPhotoBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: pickImageCamera,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.orange,
                  shadowColor: Colors.orange,
                  elevation: 5,
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.camera),
                    Text(
                      'OPEN CAMERA',
                      style: TextStyle(
                          color: Color(0xffF37335),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: pickImageOnPhotos,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.orange,
                  shadowColor: Colors.orange,
                  elevation: 5,
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined),
                    Text(
                      'TAKE PHOTO',
                      style: TextStyle(
                          color: Color(0xffF37335),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: _imageFile != null ? 200 : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: _imageFile != null
                      ? Image.file(_imageFile!)
                      : Text(
                          'Open Camera or Take Photo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Description',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ]),
            height: 60,
            child: TextFormField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              keyboardType: TextInputType.text,
              validator: (value) =>
                  value!.isEmpty ? 'Description can\'t be empty' : null,
              onSaved: (value) => _description = value!,
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                  errorStyle: TextStyle(
                    fontSize: 15.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 15, left: 50),
                  prefixIcon: Icon(Icons.text_fields, color: Color(0xffF37335)),
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.black38)),
            ))
      ],
    );
  }

  Widget buildType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: DropdownButtonFormField(
            isExpanded: true,
            value: _type,
            onChanged: (String? newValue) {
              setState(() {
                _type = newValue!;
              });
            },
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                errorStyle: TextStyle(
                  fontSize: 15.0,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 13, left: 10),
                prefixIcon: Icon(Icons.home, color: Color(0xffF37335)),
                hintText: 'Type',
                hintStyle: TextStyle(color: Colors.black38)),
            items: Constants.listType
                .map((String valueItem) {
                  return DropdownMenuItem<String>(
                      value: valueItem, child: Text(valueItem));
                })
                .cast<DropdownMenuItem<String>>()
                .toList(),
          ),
        )
      ],
    );
  }

  Widget buildEmergency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Emergency',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: DropdownButtonFormField(
            isExpanded: true,
            value: _warningLevel,
            onChanged: (String? newValue) {
              setState(() {
                _warningLevel = newValue!;
              });
            },
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                errorStyle: TextStyle(
                  fontSize: 15.0,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 13, left: 10),
                prefixIcon: Icon(Icons.error_sharp, color: Color(0xffF37335)),
                hintText: 'Emergency',
                hintStyle: TextStyle(color: Colors.black38)),
            items: Constants.listEmergency
                .map((String valuesItem) {
                  return DropdownMenuItem<String>(
                      value: valuesItem, child: Text(valuesItem));
                })
                .cast<DropdownMenuItem<String>>()
                .toList(),
          ),
        )
      ],
    );
  }

  Widget buildUploadBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: ElevatedButton(
          onPressed: validateAndSubmit,
          style: ElevatedButton.styleFrom(
            primary: Color(0xffF37335),
            onPrimary: Colors.white,
            shadowColor: Colors.orange,
            elevation: 5,
            padding: EdgeInsets.all(15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_rounded),
              Text(
                'UPLOAD',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )),
    );
  }
}
