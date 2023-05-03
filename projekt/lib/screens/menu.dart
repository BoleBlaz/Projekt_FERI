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
                    onPressed: someFunction,
                  ),
                ],
              ),
              body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple,
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
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Milijonar",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Pacifico',
                            ),
                          ),
                          SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Play quiz'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 80),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ])),
            ),
          );
        });
  }
  
  void someFunction() async {
    String? username = await User.getUsernameFromPreferences();
    User user = await User.getByUsername(username.toString());
    print("username: "+user.username);
    print("pass(bycript): "+user.password);
    print("trophies: "+user.trophies.toString());
    print("streak: "+user.streak.toString());
    print("totalGames: "+user.totalGames.toString());
    // continue with other operations on the retrieved user object
  }
}
