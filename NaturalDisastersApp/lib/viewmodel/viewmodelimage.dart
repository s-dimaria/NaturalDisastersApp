import 'package:natural_disaster_app/model/image.dart';

class ViewModelImage {
  ModelImage _imageModel;

  ViewModelImage({required ModelImage image}) : _imageModel = image;

  String get userId {
    return _imageModel.userId;
  }

  String get urlImage {
    return _imageModel.urlImage;
  }

  String get description {
    return _imageModel.description;
  }

  double get latitude {
    return _imageModel.latitude;
  }

  double get longitude {
    return _imageModel.longitude;
  }

  String? get street {
    return _imageModel.street;
  }

  String? get locality {
    return _imageModel.locality;
  }

  String get date {
    return _imageModel.date;
  }

  String? get place {
    return _imageModel.place;
  }

  String get emergencyType {
    return _imageModel.emergencyType;
  }

  int get urgency {
    return _imageModel.urgency;
  }

  String get state {
    return _imageModel.state;
  }
}
