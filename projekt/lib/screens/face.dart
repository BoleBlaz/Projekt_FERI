import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Face extends StatefulWidget {
  const Face({Key? key}) : super(key: key);

  @override
  _FaceState createState() => _FaceState();
}

class _FaceState extends State<Face> {
  final TextEditingController numberController = TextEditingController();

  Future<String> calculateSquare(int number) async {
    var url = Uri.parse('http://beoflere.com/FERI_projekt/faceApp');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({'number': number});

    var response = await http.post(url, headers: headers, body: body);
    print('Response Body: ${response.body}');
    print('Response Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      var square = result['square'];
      return square.toString();
    } else {
      throw Exception('Failed to calculate square');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Python Integration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: numberController,
              decoration: InputDecoration(labelText: 'Enter a number'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final number = int.tryParse(numberController.text);
                if (number != null) {
                  try {
                    final squareResult = await calculateSquare(number);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Square Result'),
                          content: Text('The square is: $squareResult'),
                          actions: [
                            TextButton(
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Failed to calculate square'),
                          actions: [
                            TextButton(
                              child: Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: Text('Calculate Square'),
            ),
          ],
        ),
      ),
    );
  }
}
