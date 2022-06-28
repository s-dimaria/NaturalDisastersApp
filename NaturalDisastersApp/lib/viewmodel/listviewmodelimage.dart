import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:natural_disaster_app/constant/enumtype.dart';
import 'package:natural_disaster_app/model/image.dart';
import 'package:natural_disaster_app/service/firebase/dbfirebase_realtime.dart';
import 'package:natural_disaster_app/viewmodel/viewmodelimage.dart';

class ListViewModelImage with ChangeNotifier {
  late List<ViewModelImage> _images = <ViewModelImage>[];

  late Map<String, dynamic> _mapImages = Map<String, dynamic>();

  late StreamSubscription<Event> _streamImages;

  late BitmapDescriptor mapMarkerResolved, mapMarkerNotResolved;

  late Role role;

  ListViewModelImage({required this.role}) {
    if (role == Role.admin) {
      fetchImages();
      setCustomMarker();
    } else {
      fetchImagesUser();
    }
  }

  List<ViewModelImage> get images => _images;
  Map<String, dynamic> get mapImages => _mapImages;

  @override
  void dispose() {
    _streamImages.cancel();
    super.dispose();
  }

  void setCustomMarker() async {
    mapMarkerNotResolved = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/marker_not_resolved.png');

    mapMarkerResolved = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/marker_resolved.png');
  }

  void fetchImages() {
    print("FETCH DATA ADMIN");
    BasedbFirebaseRealtime dbRealtime = DbFirebaseRealtime();
    Map<String, dynamic> _mapImg = Map<String, dynamic>();
    _streamImages = dbRealtime.getStreamImage().listen((event) {
      _mapImages.clear();
      if (event.snapshot.value != null) {
        Map _imagesData = event.snapshot.value;
        _imagesData.forEach((key, value) {
          final _allImagesData = Map<String, dynamic>.from(value);
          _mapImg.addAll(_allImagesData);
        });
        _mapImages = _mapImg;
      }
      notifyListeners();
    });
  }

  void fetchImagesUser() {
    print("FETCH DATA");
    BasedbFirebaseRealtime dbRealtime = DbFirebaseRealtime();
    List<ModelImage> _img = <ModelImage>[];
    _streamImages = dbRealtime.getStreamImageUser().listen((event) {
      _images = [];
      if (event.snapshot.value != null) {
        final _allImagesData = Map<String, dynamic>.from(event.snapshot.value);
        _img.addAll(_allImagesData.values
            .map((imageJson) =>
                ModelImage.fromJson(Map<String, dynamic>.from(imageJson)))
            .toList());
        _images = _img.map((image) => ViewModelImage(image: image)).toList();
      }
      notifyListeners();
      _img.clear();
    });
  }
}
