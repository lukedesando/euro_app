import 'package:euro_app/score_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eurovision Voting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VotePage(),
    );
  }
}

class VotePage extends StatefulWidget {
  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  String selectedSong = '';
  double _currentScore = 5.0; // Default score
  final TextEditingController nameController = TextEditingController();

  void onScoreChanged(double newScore) {
    setState(() {
      _currentScore = newScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vote for Eurovision Song'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Song:'),
            DropDown(
              items: ['Song 1', 'Song 2', 'Song 3'], // Add your song list here
              hint: Text('Select Song'),
              onChanged: (value) {
                setState(() {
                  selectedSong = value.toString();
                });
              },
            ),
            SizedBox(height: 20),
            Text('Choose Score:'),
            VotingSlider(onScoreChanged: onScoreChanged),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveVote();
              },
              child: Text('Save Vote'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    // MaterialPageRoute(builder: (context) => HomePage()),
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );  
                },
                // style: ElevatedButton.styleFrom(primary: Colors.blue),
                child: Text('Show Me Another Style'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveVote() async {
    final url = 'YOUR_API_URL_HERE'; // Replace with your API endpoint
    final response = await http.post(
      Uri.parse(url),
      body: {
        'song_name': selectedSong,
        'score': _currentScore,
        'user_name': nameController.text,
      },
    );
    if (response.statusCode == 200) {
      // Vote saved successfully
      // You can add a success message or navigate to a different screen here
    } else {
      // Error saving vote
      // You can show an error message to the user here
    }
  }
}

