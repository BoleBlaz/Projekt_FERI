// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:projekt/settings/profile.dart';
import '../models/user.dart';
import 'package:projekt/models/location.dart' as LocationModel;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock/wakelock.dart';

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
                            Text("Id: ${_user!.id}"),
                            Text("Username: ${_user!.username}"),
                            SizedBox(height: 40),
                            Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                            Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                            Text('ADDRESS: ${_currentAddress ?? ""}'),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                LocationModel.Location.getRouteNumByUserId(
                                        _user!.id)
                                    .then((var routeNum) {
                                  start((routeNum! + 1));
                                });
                              },
                              child: const Text("START"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                stop();
                              },
                              child: const Text("STOP"),
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

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.street}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      Geolocator.getLastKnownPosition();
      debugPrint(e);
    });
  }
 
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        Geolocator.openLocationSettings();
        isRunning = false;
        err = "ERROR!";
      });
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    setState(() {});
    return true;
  }

  void addLocation(int route_num) async {
    var user_id = _user!.id;
    var date = DateTime.now();
    var location = LocationModel.Location(
        latitude: _currentPosition?.latitude ?? -1,
        longitude: _currentPosition?.longitude ?? -1,
        address: _currentAddress ?? "",
        date: date,
        route_num: route_num,
        user_id: user_id);

    if (location.latitude == -1 || location.longitude == -1) {
      setState(() {
        err = "Vklopi lokacijo!";
      });
      return;
    }
    var success = await location.saveLocation();
    if (success) {
      setState(() {
        err = "ok";
      });
    } else {
      setState(() {
        err = "error. Ni mogoče dodati lokacije";
      });
    }
  }

  void start(int route_num) async {
    isRunning = true;
    while (isRunning) {
      await _getCurrentPosition();
      await Future.delayed(Duration(milliseconds: 500));
      addLocation(route_num);
    }
  }

  void stop() async {
    isRunning = false;
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      err = "Stopped";
    });
  }
}
