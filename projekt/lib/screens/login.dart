// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:projekt/screens/menu.dart';
import 'package:projekt/screens/face.dart';
import 'package:projekt/screens/register.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  String? response;

  showMenuPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MenuScreen()),
      (route) => false, // Always return false to remove all routes
    );
  }

  showRegisterPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => RegisterScreen()),
      (route) => false, // Always return false to remove all routes
    );
  }

  showFacePage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Face();
    }));
  }

   @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: "Prijava",
    home: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/road-leading-mountain-range-with-blue-sky-clouds.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Prijava",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Pacifico',
                ),
              ),
              SizedBox(height: 32),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Uporabniško ime',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Geslo',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                response??"",
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: getLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Prijava',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Še niste registrirani? ",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  GestureDetector(
                    onTap: () {
                      showRegisterPage();
                    },
                    child: Text(
                      "Ustvarite nov račun",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}



  void getLogin() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        response = "Vnesite uporabniško ime in geslo!";
      });
      return;
    }
    var user = User(username: username, password: password);
    var success = await user.getLogin();
    if (success) {
      showMenuPage();
    } else {
      setState(() {
        response = "Napačno uporabniško ime ali geslo!";
      });
    }
  }
}
