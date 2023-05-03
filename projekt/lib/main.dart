import 'package:flutter/material.dart';
import 'package:projekt/screens/login.dart';
import 'package:projekt/screens/menu.dart';
import 'package:projekt/screens/register.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projekt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String response = "";

  @override
  void initState() {
    super.initState();
    User.getUsernameFromPreferences().then((username) {
      if (username != null) {
        // User preference is set, navigate to MenuScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MenuScreen()),
          (route) => false, // Always return false to remove all routes
        );
      } else {
        // User preference is not set, stay on MainPage
        setState(() {
          response = "";
        });
      }
    });
  }
  
  showRegisterPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RegisterScreen();
    }));
  }

  showLoginPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black87, Color.fromARGB(255, 121, 33, 243)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Projekt",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Pacifico',
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: showRegisterPage,
                child: Text('Registracija'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  fixedSize: Size(250, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: showLoginPage,
                child: Text('Prijava'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  fixedSize: Size(250, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                response,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

