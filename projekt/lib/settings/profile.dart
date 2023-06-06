import 'package:flutter/material.dart';
import 'package:projekt/main.dart';
import 'package:projekt/models/user.dart';
import 'package:camera/camera.dart';
import 'package:projekt/screens/addFace.dart';
import 'package:projekt/screens/login.dart';

class Profile extends StatefulWidget {
  final String username;

  const Profile({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    _user;
    super.dispose();
  }

  Future<void> _getUserData() async {
    User user = await User.getByUsername(widget.username);
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  logoutAndShowMain() async {
    await User.clearUsernameFromPreferences();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text("Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logoutAndShowMain,
          ),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/futuristic-finance-digital-market-graph-user-interface-with-diagram-technology-hud-graphic-concept.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Username: ${_user!.username}",
                        style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        "ID: ${_user!.id}",
                        style: const TextStyle(
                            fontSize: 24.0, color: Colors.white),
                      ),
                      Text(
                        "2FA: ${_user!.fa}",
                        style: const TextStyle(
                            fontSize: 24.0, color: Colors.white),
                      ),
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: () async {
                          List<CameraDescription> cameras =
                              await availableCameras();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddFace(
                                cameras: cameras,
                                userfa: _user!.fa,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _user!.fa == 0
                            ? const Text("Dodajanje obraza (2FA)")
                            : const Text("Preverjanje obraza (2FA)"),
                      ),
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: logoutAndShowMain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Odjava',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
