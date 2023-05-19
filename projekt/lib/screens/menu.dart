// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projekt/settings/profile.dart';
import '../models/user.dart';
import 'package:projekt/models/location.dart' as LocationModel;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock/wakelock.dart';
import 'package:camera/camera.dart';
import 'package:projekt/screens/addFace.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String err = "NULL";
  String? _currentAddress;
  Position? _currentPosition;
  User? _user;
  bool isRunning = false;
  List<double>? _gyroscopeValues;
  List<double>? _accelerometerValues;
  StreamSubscription<Position>? _positionStream;
  int? _routeNum;

  Future<bool> checkAwake() async {
    bool ison = await Wakelock.enabled;
    return ison;
  }

  Future<void> _getUserData() async {
    String? username = await User.getUsernameFromPreferences();
    User user = await User.getByUsername(username!);
    setState(() {
      _user = user;
    });
  }

  showSettingsPage() async {
    String? username = await User.getUsernameFromPreferences();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Profile(username: username ?? "");
    }));
  }

  Future<String> showUser() async {
    String? username = await User.getUsernameFromPreferences();
    return username ?? "";
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _getUserData();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    });
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: showUser(),
        builder: (context, snapshot) {
          return MaterialApp(
            title: "Meni",
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 126, 42, 228),
                title: Text("Menu"),
                actions: [
                  IconButton(
                      icon: Icon(Icons.settings), onPressed: showSettingsPage),
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {},
                  ),
                ],
              ),
              body: _user == null
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: const [
                            Colors.purple,
                            Color.fromARGB(255, 121, 33, 243)
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await availableCameras().then((value) =>
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                AddFace(cameras: value))));
                              },
                              child: Text("FACE"),
                            ),
                            Text("Id: ${_user!.id}"),
                            Text("Username: ${_user!.username}"),
                            SizedBox(height: 40),
                            Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                            Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                            Text('ADDRESS: ${_currentAddress ?? ""}'),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: isRunning
                                  ? null
                                  : () {
                                      LocationModel.Location
                                              .getRouteNumByUserId(_user!.id)
                                          .then((var routeNum) {
                                        _routeNum = routeNum! + 1;
                                        //start();
                                        _startListening();
                                      });
                                    },
                              child: const Text("START"),
                            ),
                            ElevatedButton(
                              onPressed: !isRunning
                                  ? null
                                  : () {
                                      stop();
                                      setState(() {
                                        isRunning = false;
                                      });
                                    },
                              child: Text("STOP"),
                            ),
                            SizedBox(height: 20),
                            Text(
                              err,
                              style: TextStyle(color: Colors.red, fontSize: 30),
                            ),
                            Text(
                              "x: ${_gyroscopeValues![0]}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              "y: ${_gyroscopeValues![1]}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              "z: ${_gyroscopeValues![2]}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "x: ${_accelerometerValues![0]}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              "y: ${_accelerometerValues![1]}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              "z: ${_accelerometerValues![2]}",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            FutureBuilder<bool>(
                                future: checkAwake(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<bool> snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data == true) {
                                      return Text(
                                          "Screen is on stay awake mode.");
                                    } else {
                                      return Text(
                                          "Screen is not on stay awake mode.");
                                    }
                                  } else {
                                    return Text(
                                        "Error while reading awake state.");
                                  }
                                }),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentPosition = position;
        _currentAddress = '${place.street}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void addLocation() async {
    var user_id = _user!.id;
    var date = DateTime.now();
    var location = LocationModel.Location(
        latitude: _currentPosition?.latitude ?? -1,
        longitude: _currentPosition?.longitude ?? -1,
        address: _currentAddress ?? "",
        date: date,
        route_num: _routeNum ?? -1,
        user_id: user_id);

    if (location.latitude == -1 || location.longitude == -1) {
      print("Vklopi lokacijo!");
      return;
    }

    if (location.route_num == -1) {
      print("routeNum error!");
      return;
    }

    String lat = location.latitude.toString();
    String lon = location.latitude.toString();
    int indLat = lat.indexOf('.');
    int indLon = lon.indexOf('.');
    int decimalPlacesLat = lat.length - indLat - 1;
    int decimalPlacesLon = lon.length - indLon - 1;

    if (decimalPlacesLat != 7 || decimalPlacesLon != 7) {
      print("Premalo decimalk!");
      return;
    }

    var success = await location.saveLocation();
    if (success) {
      print("ok");
    } else {
      setState(() {
        isRunning = false;
        err = "ne gre v bazo!";
      });
    }
  }

  void _startListening() async {
    isRunning = true;
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isRunning = false;
      setState(() {
        err = "Location services are disabled.";
      });
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isRunning = false;
        setState(() {
          err = "Location permissions are denied";
        });
      }
    }
    if (permission == LocationPermission.deniedForever) {
      isRunning = false;
      setState(() {
        err =
            "Location permissions are permanently denied, we cannot request permissions.";
      });
    }

    _positionStream =
        Geolocator.getPositionStream().listen((Position? position) {
      if (position == null) {
        print("error. position==null");
      } else if(_currentPosition == null || _currentAddress == null){
        print("error. _currentPosition==null || _currentAddress==null");
        _getAddressFromLatLng(position);
      }else{
        _getAddressFromLatLng(position);
        print(_currentPosition);
        print(_currentAddress);
        addLocation();
      }
    });
  }

  /*void start() async {
    isRunning = true;
    setState(() {
      err = "Running";
    });
    while (isRunning) {
      Position position = await _determinePosition();
      print(position);
      _getAddressFromLatLng(position);
      await Future.delayed(Duration(milliseconds: 500));
      addLocation();
    }
  }*/

  void stop() async {
    isRunning = false;
    _positionStream?.cancel();
    setState(() {
      err = "Stopped";
    });
  }
}
