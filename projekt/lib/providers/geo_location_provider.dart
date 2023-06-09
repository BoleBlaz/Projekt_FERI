import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projekt/widgets/speedo_meter.dart';
import 'dart:async';

class GeoLocationProvider extends ChangeNotifier {
  final MapController mapController = MapController();
  double speed = 0.00;
  List<double> speedSequence = [0, 0];

  Timer? _myLocationChecker;

  void initGeoLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      myLocationChecker();
      return Future.error('Location services are disabled.');
    } else if (_myLocationChecker != null) {
      _myLocationChecker?.cancel();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final curruntPosition = await Geolocator.getCurrentPosition();
    updateMyLocation(curruntPosition);

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    resetSpeed();

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      updateMyLocation(position);
    });
  }

  void resetSpeed() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      speed = 0.00;
      notifyListeners();
    });
  }

  void myLocationChecker() async {
    _myLocationChecker =
        Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      final curruntPosition = await Geolocator.getCurrentPosition();
      updateMyLocation(curruntPosition);
      if (await Geolocator.isLocationServiceEnabled())
        return _myLocationChecker?.cancel();
    });
  }

  void updateMyLocation(Position? curruntPosition) {
    if (curruntPosition == null) return;
    mapController.rotate(curruntPosition.heading);
    mapController.move(
        LatLng(curruntPosition.latitude, curruntPosition.longitude), 17);

    speed = (curruntPosition.speed * (3600 / 1000)).abs(); // speed in KM/h
    if (curruntPosition.speed > topSpeed) {
      speed = topSpeed.toDouble();
    }
    speedSequence.add(speed);
    speedSequence.removeAt(0);
    notifyListeners();
  }
}
