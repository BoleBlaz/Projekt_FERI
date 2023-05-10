// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:projekt/models/user.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String response = "";

  showLoginPage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Registracija",
      home: Scaffold(
        body: Container(
          child: Scaffold(
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
                    Text(
                      "Registracija",
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
                        controller: this.usernameController,
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
                        controller: this.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Geslo',
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
                        controller: this.confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'Potrdi geslo',
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      response,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: addUser,
                        child: Text('Registriraj'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Že imate račun? ",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        GestureDetector(
                          onTap: () {
                            showLoginPage();
                          },
                          child: Text(
                            "Prijavite se",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addUser() async {
    String username = usernameController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        response = "Vnesite uporabniško ime in geslo!";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        response = "Gesli se ne ujemata!";
      });
      return;
    }

    var user = User(username: username, password: password);
    var success = await user.saveUser();
    if (success) {
      showLoginPage();
    } else {
      setState(() {
        response = "Uporabnikšo ime je že zasedeno!";
      });
    }
  }
}
