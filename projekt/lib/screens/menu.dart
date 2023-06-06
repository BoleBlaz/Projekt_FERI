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
import 'package:projekt/screens/login.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String err = "";
  String text = "";
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
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  showSettingsPage() async {
    String? username = await User.getUsernameFromPreferences();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Profile(
        username: username ?? "",
      );
    }));
  }

  Future<String> showUser() async {
    String? username = await User.getUsernameFromPreferences();
    return username ?? "";
  }

  logoutAndShowMain() async {
    await User.clearUsernameFromPreferences();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Cancel the position stream if it exists
    gyroscopeEvents.drain(); // Stop listening to gyroscope events
    accelerometerEvents.drain(); // Stop listening to accelerometer events
    Wakelock.disable(); // Disable wakelock to allow the device to sleep
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _getUserData();
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
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
              title: Text("Menu"),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: showSettingsPage,
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: logoutAndShowMain,
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.only(
                            left: 40, right: 40, top: 10, bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /*ElevatedButton(
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
                          ),*/
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
                                      if (mounted) {
                                        setState(() {
                                          isRunning = false;
                                          text = "Stopped";
                                        });
                                      }
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
                            Text('LAT: ${_currentPosition?.latitude ?? ""}',
                                style: TextStyle(color: Colors.white)),
                            Text('LNG: ${_currentPosition?.longitude ?? ""}',
                                style: TextStyle(color: Colors.white)),
                            Text('ADDRESS: ${_currentAddress ?? ""}',
                                style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 20),
                            Text("hitrost: ${velocity.toStringAsFixed(2)}",
                                style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 20),
                            SizedBox(height: 20),
                            Text(
                              "Stanje:",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            Text(
                              text,
                              style:
                                  TextStyle(color: Colors.green, fontSize: 20),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Error:",
                              style: err.isEmpty
                                  ? null
                                  : TextStyle(
                                      color: Colors.white, fontSize: 10),
                            ),
                            Text(
                              err,
                              style: err.isEmpty
                                  ? null
                                  : TextStyle(color: Colors.red, fontSize: 20),
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
                          ),*/
                          ],
                        ),
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
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _currentAddress = '${place.street}, ${place.postalCode}';
        });
      }
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void script() {
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
      if (mounted) {
        setState(() {
          isRunning = false;
          err = "ne gre v bazo!";
        });
      }
    }
  }

  void _startListening() async {
    isRunning = true;
    bool serviceEnabled;
    LocationPermission permission;
    if (mounted) {
      setState(() {
        err = "";
      });
    }
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isRunning = false;
      if (mounted) {
        setState(() {
          err = "Location services are disabled";
        });
      }
    } else {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isRunning = false;
          if (mounted) {
            setState(() {
              err = "Location permissions are denied";
            });
          }
        }
      } else {
        if (permission == LocationPermission.deniedForever) {
          isRunning = false;
          if (mounted) {
            setState(() {
              err =
                  "Location permissions are permanently denied, we cannot request permissions";
            });
          }
        } else {
          if (mounted) {
            setState(() {
              text = "Running";
            });
          }
          const LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
          );
          gyroscopeEvents.listen((GyroscopeEvent event) {
            if (mounted) {
              setState(() {
                _gyroscopeValues = <double>[event.x, event.y, event.z];
              });
            }
          });
          accelerometerEvents.listen((AccelerometerEvent event) {
            if (mounted) {
              setState(() {
                _accelerometerValues = <double>[event.x, event.y, event.z];
              });
            }
          });
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
              if (mounted) {
                setState(() {
                  velocity = (position.speed * 3.6);
                });
              }
            }
          });
        }
      }
    }
  }

  void stop() async {
    isRunning = false;
    _positionStream?.cancel(); // Cancel the position stream if it exists
    gyroscopeEvents.drain(); // Stop listening to gyroscope events
    accelerometerEvents.drain(); // Stop listening to accelerometer events
  }
}
