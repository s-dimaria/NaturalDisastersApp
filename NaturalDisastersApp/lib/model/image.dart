class ModelImage {
  late String userId;
  late String urlImage;
  late String description;
  late double latitude;
  late double longitude;
  late String? street;
  late String? locality;
  late String date;
  late String? place;
  late String emergencyType;
  late int urgency;
  late String state;

  ModelImage(
      this.userId,
      this.urlImage,
      this.description,
      this.latitude,
      this.longitude,
      this.street,
      this.locality,
      this.date,
      this.place,
      this.emergencyType,
      this.urgency,
      this.state);

  ModelImage.fromJson(Map<dynamic, dynamic> json)
      : userId = json['userId'],
        urlImage = json['urlImage'],
        description = json['description'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        street = json['street'],
        locality = json['locality'],
        date = json['date'],
        place = json['place'],
        emergencyType = json['emergencyType'],
        urgency = json['urgency'],
        state = json['state'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'userId': userId,
        'urlImage': urlImage,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'street': street,
        'locality': locality,
        'date': date,
        'place': place,
        'emergencyType': emergencyType,
        'urgency': urgency,
        'state': state
      };
}
