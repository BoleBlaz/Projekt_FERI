import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login.dart';
import 'package:projekt/screens/menu.dart';
import 'package:projekt/screens/face.dart';
import 'package:projekt/screens/register.dart';
import 'models/user.dart';
import 'providers/geo_location_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GeoLocationProvider>(
          create: (_) => GeoLocationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Projekt',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    User.getUsernameFromPreferences().then((username) {
      if (username != null) {
        // User preference is set, navigate to MenuScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MenuScreen()),
          (route) => false, // Always return false to remove all routes
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // Always return false to remove all routes
        );
      }
    });
  }

  void showRegisterPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const RegisterScreen();
    }));
  }

  void showLoginPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const LoginScreen();
    }));
  }

  void showFacePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const Face();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
