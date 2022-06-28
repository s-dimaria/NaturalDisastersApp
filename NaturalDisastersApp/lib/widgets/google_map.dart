import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:natural_disaster_app/model/image.dart';
import 'package:natural_disaster_app/service/multiple_provider.dart';
import 'package:natural_disaster_app/viewmodel/listviewmodelimage.dart';
import 'package:natural_disaster_app/viewmodel/viewmodelimage.dart';
import 'package:provider/provider.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = Set<Marker>();
  List<Widget> _gestureList = <Widget>[];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _goToLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 20,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return _buildStream();
  }

  Widget _buildStream() {
    return Consumer<ListViewModelImage>(builder: (context, model, child) {
      final markers = Set<Marker>();
      final gestureImage = <Widget>[];
      model.mapImages.forEach((key, value) {
        ViewModelImage element =
            ViewModelImage(image: ModelImage.fromJson(value));
        Widget _gestWidget = _boxes(
            element.urlImage,
            element.latitude,
            element.longitude,
            element.place ?? "place",
            element.date,
            element.emergencyType,
            element.state,
            element.urgency,
            element.locality ?? "locality",
            element.street ?? "street");
        Marker markerImage = Marker(
            markerId: MarkerId(element.date + element.urlImage),
            position: LatLng(element.latitude, element.longitude),
            icon: (element.state == "Pendente")
                ? model.mapMarkerNotResolved
                : model.mapMarkerResolved,
            infoWindow: InfoWindow(
              title: element.place,
              snippet: element.description,
              onTap: () => element.state == "Pendente"
                  ? _showMyDialogEditImage(key, element.userId)
                  : {},
            ),
            onTap: () {
              _goToLocation(element.latitude, element.longitude);
            });
        markers.add(markerImage);
        gestureImage.add(_gestWidget);
      });
      _markers = markers;
      _gestureList = gestureImage;
      return _buildUI();
    });
  }

  Widget _buildUI() {
    return Stack(
      children: [
        _buildGoogleMaps(),
        _buildContainer(),
      ],
    );
  }

  Widget _buildGoogleMaps() {
    return GoogleMap(
      markers: _markers,
      initialCameraPosition: CameraPosition(
        target: LatLng(41.90, 12.49),
        zoom: 5,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 60.0),
          height: 130.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: 10.0),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: _gestureList,
                ),
              ),
            ],
          )),
    );
  }

  Widget _boxes(
      String _image,
      double lat,
      double lon,
      String place,
      String date,
      String emergency,
      String state,
      int urg,
      String locality,
      String street) {
    return GestureDetector(
      onTap: () {
        _goToLocation(lat, lon);
      },
      child: Container(
        child: Row(
          children: [
            new FittedBox(
              child: Material(
                color: Colors.white,
                elevation: 5.0,
                borderRadius: BorderRadius.circular(24.0),
                shadowColor: Colors.orange,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 170,
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(24.0),
                        child: Image(
                          fit: BoxFit.fill,
                          image: NetworkImage(_image),
                        ),
                      ),
                    ),
                    Container(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer(
                          place, date, emergency, state, urg, street, locality),
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget myDetailsContainer(String place, String date, String emergency,
      String state, int urg, String street, String locality) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            child: Row(
              children: [
                Text(
                  emergency,
                  style: TextStyle(
                      color: Color(0xffF37335),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  " - Urgency: ",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  urg.toString(),
                  style: TextStyle(
                      color: Color(0xffF37335),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 5.0),
        Container(
          child: Text(
            place,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 20.0,
            ),
          ),
        ),
        SizedBox(height: 13.0),
        Container(
            child: Text(
          state,
          style: TextStyle(
              color: state == "Pendente" ? Colors.red : Colors.green,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
        SizedBox(height: 10.0),
        Container(
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                    text: street,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18.0,
                    ),
                    children: [
                      TextSpan(
                        text: ', ' + locality,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18.0,
                        ),
                      ),
                    ]),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ],
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
