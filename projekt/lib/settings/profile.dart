import 'package:flutter/material.dart';
import 'package:projekt/main.dart';
import 'package:projekt/models/user.dart';
import 'package:camera/camera.dart';
import 'package:projekt/screens/addFace.dart';

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
    _user = null;
    super.dispose();
  }

  Future<void> _getUserData() async {
    User user = await User.getByUsername(widget.username);
    setState(() {
      _user = user;
    });
  }

  logoutAndShowMain() async {
    await User.clearUsernameFromPreferences();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false, // Always return false to remove all routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/futuristic-finance-digital-market-graph-user-interface-with-diagram-technology-hud-graphic-concept.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Username: ${_user!.username}",
                      style: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      "ID: ${_user!.id}",
                      style:
                          const TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                    Text(
                      "2FA: ${_user!.fa}",
                      style:
                          const TextStyle(fontSize: 24.0, color: Colors.white),
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
    );
  }
}
