import 'package:flutter/material.dart';
import 'package:projekt/main.dart';
import 'package:projekt/models/user.dart';

class Profile extends StatefulWidget {
  final String username;

  const Profile({super.key, required this.username});

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

  Future<void> _getUserData() async {
    User user = await User.getByUsername(widget.username);
    setState(() {
      _user = user;
    });
  }

  logoutAndShowMain() async {
    await User.clearUsernameFromPreferences();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return const MyHomePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _user == null
            ? const Center(child: CircularProgressIndicator())
            : Container( 
              child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _user!.username,
                    style:
                        const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "ID: ${_user!.id}",
                    style: const TextStyle(fontSize: 24.0),
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: logoutAndShowMain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Odjava'),
                  ),
                ],
              ),
              ),
            ),
    );
  }
}
