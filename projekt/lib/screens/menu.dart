import 'package:flutter/material.dart';
import 'package:projekt/settings/profile.dart';
import '../models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String response = "NULL";
  String err = "NULL";
  String? _currentAddress;
  Position? _currentPosition;

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
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        err = "Vklopi lokacijo!";
      });
      print('Location services are disabled. Please enable the services');
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    setState(() {
        err = "";
      });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: showUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            response = snapshot.data!;
          }
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
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple, Color.fromARGB(255, 121, 33, 243)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                      Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                      Text('ADDRESS: ${_currentAddress ?? ""}'),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _getCurrentPosition,
                        child: const Text("Get Current Location"),
                      ),
                      SizedBox(height: 20),
                      Text(
                        err,
                        style: TextStyle(color: Colors.red, fontSize: 30),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
