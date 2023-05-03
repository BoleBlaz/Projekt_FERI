import 'package:flutter/material.dart';
import 'package:projekt/screens/menu.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String response = "";

  showMenuPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MenuScreen()),
      (route) => false, // Always return false to remove all routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Prijava",
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
                      SizedBox(height: 32),
                      Container(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: getLogin,
                          child: Text('Prijava'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
            ),
          ),
        ));
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
