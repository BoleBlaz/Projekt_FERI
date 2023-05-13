import 'dart:convert';
import 'package:http/http.dart' as http;

class Location {
  int id;
  double latitude;
  double longitude;
  String address;
  DateTime date;
  int user_id;

  Location({
    this.id = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = "",
    required this.date,
    required this.user_id,
  });

  int getId() {
    return this.id;
  }

  double getLatitude() {
    return this.latitude;
  }

  void setLatitude(double latitude) {
    this.latitude = latitude;
  }

  void setAddress(String address) {
    this.address = address;
  }

  String getAddress() {
    return this.address;
  }

  double getLongitude() {
    return this.longitude;
  }

  void setLongitude(double longitude) {
    this.longitude = longitude;
  }

  DateTime getDate() {
    return this.date;
  }

  void setDate(DateTime date) {
    this.date = date;
  }

  int getUserId() {
    return this.user_id;
  }

  void setUserId(int user_id) {
    this.user_id = user_id;
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      date: DateTime.parse(json['date']),
      user_id: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        "address": address,
        'date': date.toIso8601String(),
        'user_id': user_id,
      };

  Future<bool> saveLocation() async {
    var dataStr = jsonEncode({
      "command": "add_location",
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "date": date.toIso8601String(),
      "user_id": user_id,
    });
    var encodedData = Uri.encodeComponent(dataStr);
    var url =
        Uri.parse("http://beoflere.com/confprojekt.php?data=$encodedData");
    print(url.toString());

    try {
      var result = await http.get(url);
      if (result.body == "ERROR") {
        return false;
      }
      if (result.body == "OK") {
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }
}
