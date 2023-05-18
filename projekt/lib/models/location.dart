import 'dart:convert';
import 'package:http/http.dart' as http;

class Location {
  int id;
  double latitude;
  double longitude;
  String address;
  DateTime date;
  int route_num;
  int user_id;

  Location({
    this.id = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = "",
    required this.date,
    required this.route_num,
    required this.user_id,
  });

  int getId() {
    return id;
  }

  double getLatitude() {
    return latitude;
  }

  void setLatitude(double latitude) {
    this.latitude = latitude;
  }

  void setAddress(String address) {
    this.address = address;
  }

  String getAddress() {
    return address;
  }

  double getLongitude() {
    return longitude;
  }

  void setLongitude(double longitude) {
    this.longitude = longitude;
  }

  DateTime getDate() {
    return date;
  }

  void setDate(DateTime date) {
    this.date = date;
  }

  int getRouteNum() {
    return route_num;
  }

  void setRouteNum(int route_num) {
    this.route_num = route_num;
  }

  int getUserId() {
    return user_id;
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
      route_num: json['route_num'],
      user_id: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        "address": address,
        'date': date.toIso8601String(),
        'route_num': route_num,
        'user_id': user_id,
      };

  Future<bool> saveLocation() async {
    var dataStr = jsonEncode({
      "command": "add_location",
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
      "date": date.toIso8601String(),
      "route_num": route_num,
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

  static Future<int?> getRouteNumByUserId(int user_id) async {
    var dataStr = jsonEncode({
      "command": "get_routeNum_fromUser",
      "user_id": user_id,
    });
    var url = Uri.parse("http://beoflere.com/confprojekt.php?data=$dataStr");

    var result = await http.get(url);
    var jsonResponse = jsonDecode(result.body);
    try {
      if (result.statusCode != 200) {
        throw Exception('No rows found');
      }
      
      var data = jsonResponse[0];
      var maxRouteNumber = data['max_route_number'];
      if(maxRouteNumber == null){
        return 0;
      }
      return int.parse(maxRouteNumber);
    } catch (e) {
      throw Exception('Failed to parse JSON response: $e');
    }
  }
}
