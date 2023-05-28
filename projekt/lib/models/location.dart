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
  double accelerometer_x;
  double accelerometer_y;
  double accelerometer_z;
  double gyroscope_x;
  double gyroscope_y;
  double gyroscope_z;

  Location({
    this.id = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = "",
    required this.date,
    required this.route_num,
    required this.user_id,
    this.accelerometer_x = 0.0,
    this.accelerometer_y = 0.0,
    this.accelerometer_z = 0.0,
    this.gyroscope_x = 0.0,
    this.gyroscope_y = 0.0,
    this.gyroscope_z = 0.0,
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

  void setRouteNum(int routeNum) {
    route_num = routeNum;
  }

  int getUserId() {
    return user_id;
  }

  void setUserId(int userId) {
    user_id = userId;
  }

  double getAccelerometerX() {
    return accelerometer_x;
  }

  void setAccelerometerX(double value) {
    accelerometer_x = value;
  }

  double getAccelerometerY() {
    return accelerometer_y;
  }

  void setAccelerometerY(double value) {
    accelerometer_y = value;
  }

  double getAccelerometerZ() {
    return accelerometer_z;
  }

  void setAccelerometerZ(double value) {
    accelerometer_z = value;
  }

  double getGyroscopeX() {
    return gyroscope_x;
  }

  void SetGyroscopeX(double value) {
    gyroscope_x = value;
  }

   double getGyroscopeY() {
    return gyroscope_y;
  }

  void SetGyroscopeY(double value) {
    gyroscope_y = value;
  }

   double getGyroscopeZ() {
    return gyroscope_z;
  }

  void SetGyroscopeZ(double value) {
    gyroscope_z = value;
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
      accelerometer_x: json['accelerometer_x'],
      accelerometer_y: json['accelerometer_y'],
      accelerometer_z: json['accelerometer_z'],
      gyroscope_x: json['gyroscope_x'],
      gyroscope_y: json['gyroscope_y'],
      gyroscope_z: json['gyroscope_z'],

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
        'accelerometer_x': accelerometer_x,
        'accelerometer_y': accelerometer_y,
        'accelerometer_z': accelerometer_z,
        'gyroscope_x': gyroscope_x,
        'gyroscope_y': gyroscope_y,
        'gyroscope_z': gyroscope_z,
        
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
      "accelerometer_x": accelerometer_x,
      "accelerometer_y": accelerometer_y,
      "accelerometer_z": accelerometer_z,
      "gyroscope_x": gyroscope_x,
      "gyroscope_y": gyroscope_y,
      "gyroscope_z": gyroscope_z,
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

  static Future<int?> getRouteNumByUserId(int userId) async {
    var dataStr = jsonEncode({
      "command": "get_routeNum_fromUser",
      "user_id": userId,
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
      if (maxRouteNumber == null) {
        return 0;
      }
      return int.parse(maxRouteNumber);
    } catch (e) {
      throw Exception('Failed to parse JSON response: $e');
    }
  }
}
