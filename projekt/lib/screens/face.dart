import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:process/process.dart';
import 'dart:io';

class Face extends StatefulWidget {
  const Face({Key? key}) : super(key: key);

  @override
  _FaceState createState() => _FaceState();
}

class _FaceState extends State<Face> {

  final ProcessManager _processManager = const LocalProcessManager();
  String _output = "";


  final currentDirectory = Directory.current.path;
  late final pythonScriptPath = '$currentDirectory/scripts/test.py';
  Future<void> _runScript() async {
    // replace with your own Python script path
    final process = await _processManager.start(['python', pythonScriptPath]);

    // listen for stdout from the Python script
    process.stdout.transform(utf8.decoder).listen((data) {
      setState(() {
        _output += data;
      });
    });

    // listen for stderr from the Python script
    process.stderr.transform(utf8.decoder).listen((data) {
      setState(() {
        _output += data;
      });
    });

    // wait for the Python script to complete
    await process.exitCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _runScript,
              child: Text("Run Script"),
            ),
            SizedBox(height: 20),
            Text(_output),
          ],
        ),
      ),
    );
  }
}
    
