// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projekt/settings/profile.dart';
import '../models/user.dart';
import 'package:projekt/models/location.dart' as LocationModel;
import 'package:projekt/models/image.dart' as ImageModel;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock/wakelock.dart';
import 'package:projekt/speede_meter_home.dart';

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
  double velocity = 0.0;

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
      return Profile(username: username ?? "",);
    }));
  }

  Future<String> showUser() async {
    String? username = await User.getUsernameFromPreferences();
    return username ?? "";
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Cancel the position stream if it exists
    gyroscopeEvents.drain(); // Stop listening to gyroscope events
    accelerometerEvents.drain(); // Stop listening to accelerometer events
    _positionStream?.cancel();
    Wakelock.disable(); // Disable wakelock to allow the device to sleep
    super.dispose();
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
          title: "Menu",
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 57, 100, 180),
              title: Text("Menu"),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: showSettingsPage,
                ),
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
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/futuristic-finance-digital-market-graph-user-interface-with-diagram-technology-hud-graphic-concept.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Text('LAT: ${_currentPosition?.latitude ?? ""}',
                              style: TextStyle(color: Colors.white)),
                          Text('LNG: ${_currentPosition?.longitude ?? ""}',
                              style: TextStyle(color: Colors.white)),
                          Text('ADDRESS: ${_currentAddress ?? ""}',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SpeedometerHome(),
                                ),
                              );
                            },
                            child: const Text("Open Speedometer"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: isRunning
                                ? null
                                : () {
                                    LocationModel.Location.getRouteNumByUserId(
                                            _user!.id)
                                        .then((var routeNum) {
                                      _routeNum = routeNum! + 1;
                                      //start();
                                      setState(() {
                                        err = "Running";
                                      });
                                      _startListening();
                                    });
                                  },
                            child: const Text("START"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
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
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            err,
                            style: TextStyle(color: Colors.red, fontSize: 30),
                          ),
                          /*
                          Text(
                            "x: ${_gyroscopeValues![0]}",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "y: ${_gyroscopeValues![1]}",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "z: ${_gyroscopeValues![2]}",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "x: ${_accelerometerValues![0]}",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "y: ${_accelerometerValues![1]}",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "z: ${_accelerometerValues![2]}",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          */
                          Text(
                            "hitrost: ${velocity.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: script,
                            child: Text("script"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
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

  void script(){
    ImageModel.Image.runScriptWithUserId(_user!.id);
  }

  void addLocation() async {
    var userId = _user!.id;
    var date = DateTime.now();
    var location = LocationModel.Location(
        latitude: _currentPosition?.latitude ?? -1,
        longitude: _currentPosition?.longitude ?? -1,
        address: _currentAddress ?? "",
        date: date,
        route_num: _routeNum ?? -1,
        user_id: userId,
        accelerometer_x: _accelerometerValues?[0] ?? -999,
        accelerometer_y: _accelerometerValues?[1] ?? -999,
        accelerometer_z: _accelerometerValues?[2] ?? -999,
        gyroscope_x: _gyroscopeValues?[0] ?? -999,
        gyroscope_y: _gyroscopeValues?[1] ?? -999,
        gyroscope_z: _gyroscopeValues?[2] ?? -999,
        speed: velocity);

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

    if (decimalPlacesLat < 7 || decimalPlacesLon < 7) {
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

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position == null) {
        print("error. position==null");
      } else if (_currentPosition == null || _currentAddress == null) {
        print("error. _currentPosition==null || _currentAddress==null");
        _getAddressFromLatLng(position);
      } else {
        _getAddressFromLatLng(position);
        addLocation();
        setState(() {
          velocity = (position.speed * 3.6);
        });
      }
    });
  }

  void stop() async {
    isRunning = false;
    _positionStream?.cancel();
    setState(() {
      err = "Stopped";
    });
  }
}
