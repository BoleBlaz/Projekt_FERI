import 'package:flutter/material.dart';
import 'package:projekt/settings/profile.dart';
import '../models/user.dart';



class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String response = "NULL";

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
                      colors: [
                        Colors.black87,
                        Color.fromARGB(255, 121, 33, 243)
                      ],
                    ),
                  ),
                  child: Stack(children: [
                    Positioned(
                      top: 100,
                      left: 20,
                      child: Text(
                        "Pozdravljen: " + response,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ])),
            ),
          );
        });
  }
}
