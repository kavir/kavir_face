import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:senti_app/apps/login.dart';
import 'package:senti_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> detectedEmotions = [];
  String storedUserId = ''; // Declare storedUserId variable
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<MusicInfo> recommendedMusic = [];
  List<dynamic> results = [];

  String currentEmotion = 'Detecting...'; // Variable to store current emotion
  int _selectedIndex = 0; // Index for selected tab

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id'); // Retrieve stored user ID
    if (userId != null) {
      setState(() {
        storedUserId = userId; // Set storedUserId state
      });
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException(
        'No camera available',
        'NoCameraAvailable',
      );
    }
    _controller = CameraController(
      cameras[1],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
    _startContinuousProcessing();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startContinuousProcessing() async {
    while (true) {
      await Future.delayed(Duration(seconds: 3)); // Adjust interval as needed
      await processEmotion();
    }
  }

//   Future<void> averageEmotion() async {
//     List<Object?> mostCommonEmotions = findMostCommonEmotions(detectedEmotions);
//     print('Most common emotions: $mostCommonEmotions');
//   }

// // Function to find the most common emotions
//   List<Object?> findMostCommonEmotions(List<String> emotions) {
//     // Create a map to store the count of each emotion
//     final Map<String, int> emotionCount = {};

//     // Iterate over the emotions and count occurrences
//     emotions.forEach((emotion) {
//       emotionCount[emotion] = (emotionCount[emotion] ?? 0) + 1;
//     });

//     // Sort the map by value (count) in descending order
//     final sortedEmotionCount = SplayTreeMap.from(
//       emotionCount,
//       (a, b) => emotionCount[b]!.compareTo(emotionCount[a]!),
//     );

//     // Get the keys (emotions) from the sorted map
//     final List<Object?> sortedEmotions = sortedEmotionCount.keys.toList();

//     // Return the top 3 most common emotions
//     return sortedEmotions.take(3).toList();
//   }

  Future<void> processEmotion() async {
    try {
      await _initializeControllerFuture;

      // Take a picture and get the file path
      XFile file = await _controller.takePicture();

      // Convert image to bytes
      Uint8List imageBytes = await File(file.path).readAsBytes();

      // Base64 encode the image
      String base64Image = base64Encode(imageBytes);

      // Replace 'your-flask-server-url' with the actual URL where your Flask server is running
      final response = await http.post(
        Uri.parse('http://192.168.1.68:5000/process_emotion'),
        body: {'image': base64Image},
      );
      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        if (responseBody is List) {
          results = responseBody;

          if (results.isNotEmpty) {
            // Process the results as needed

            String newEmotion = results.first['emotion'];
            // print('the new emotion issss::::::::::::$newEmotion');
            setState(() {
              // If the new emotion is different from the previous one
              if (newEmotion != currentEmotion) {
                recommendedMusic.clear(); // Clear the recommended music list
                currentEmotion = newEmotion; // Update current emotion
                print("the result is given as::$results");
                print(
                    '////////////////////////////////////////////////////////////////////////');

                results.forEach((result) {
                  MusicInfo musicInfo = MusicInfo.fromJson(result);
                  if (musicInfo.name.isNotEmpty) {
                    print(musicInfo.name);
                  } else {
                    print("empty");
                  }

                  recommendedMusic.add(musicInfo);
                  print(
                      'Added music: Name: ${musicInfo.name}, Artist: ${musicInfo.artist}, Album: ${musicInfo.album}');
                });
                print(
                    '////////////////////////////////////////////////////////////////////////');
                // Print the content of recommended music
                print('Recommended Music:');
                recommendedMusic.forEach((musicInfo) {
                  print(
                      'Added music 2: Name: ${musicInfo.name}, Artist: ${musicInfo.artist}, Album: ${musicInfo.album}');
                });
                detectedEmotions.add(newEmotion);
                // await averageEmotion();
              }
            });

            print("Detected Emotions: $detectedEmotions");
            // print("the recommended music is given as::");
            // recommendedMusic.forEach((music) {
            //   print(
            //       "Name: ${music.name}, Artist: ${music.artist}, Album: ${music.album}");
            // });

            print(
                "the current emotion is given or is detected as::$currentEmotion");
          }
        } else {
          // Handle response when it's not a List
          // For example, if it's a single result or an error message
          // Adjust this part according to your server's response structure
          print(responseBody);
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Recognition App'),
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Played Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_3_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  // Function to return the body based on the selected tab
  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _getCameraView();
      case 1:
        return _getMusicView();
      case 2:
        return _getProfileView(context);
      default:
        return Container();
    }
  }

  // Function to return camera view
  Widget _getCameraView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Wrap CameraPreview inside a Container with fixed width and height
        Container(
          width:
              MediaQuery.of(context).size.width * 1.5, // Adjust width as needed
          height: MediaQuery.of(context).size.height *
              0.6, // Adjust height as needed
          child: Center(
            child: FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
                      Positioned(
                        bottom: 10,
                        left: 150,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(47, 0, 0, 0).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentEmotion,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(
                                  255, 11, 240, 68), // Set text color to green
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Function to return music view
  // Function to return music view
  Widget _getMusicView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recommendedMusic.isEmpty)
            Text(
              'No recommended music available',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          // Display recommended music
          Expanded(
            child: ListView.builder(
              itemCount: recommendedMusic.length,
              itemBuilder: (context, index) {
                final music = recommendedMusic[index];
                return ListTile(
                  // title: Text("hello world from the kathmandu"),
                  title: Text("These are the recommended musics${music.name}"),
                  subtitle: Text('${music.artist} - ${music.album}'),
                  // You can add more UI elements or actions here
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _getMusicView() {
  //   return Padding(
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         if (recommendedMusic.isEmpty)
  //           Text(
  //             'No recommended music available',
  //             style: TextStyle(fontSize: 16),
  //           ),
  //         // Display recommended music
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: recommendedMusic.length,
  //             itemBuilder: (context, index) {
  //               final music = recommendedMusic[index];
  //               return ListTile(
  //                 title: Text(music.name),
  //                 subtitle: Text('${music.artist} - ${music.album}'),
  //                 // You can add more UI elements or actions here
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

Widget _getProfileView(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder(
          future: _fetchUserData(), // Function to fetch user data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error fetching user data');
            } else {
              final userData = snapshot.data as Map<String, dynamic>;
              final userName = userData['name'];
              final userEmail = userData['email'];
              final commonEmotion = userData[
                  'common_emotion']; // Correctly access common emotion field
              print("Common Emotion is $commonEmotion");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: $userName',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: $userEmail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Common Emotion: $commonEmotion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Add your music-related widgets here

                  // Division for user profile information
                  Divider(),

                  // Add a ListTile for logout button
                ],
              );
            }
          },
        ),
        SizedBox(height: 20),
        ListTile(
          title: Text('Logout'),
          trailing: Icon(Icons.logout),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final storedUserId = prefs.getString('user_id');
            final response = await http.get(
              Uri.parse('http://192.168.1.68:5000/logout'),
              headers: {
                'Authorization':
                    'Bearer $storedUserId', // Pass stored user ID in headers
              },
            );

            if (response.statusCode == 200) {
              // Logout successful, navigate to the login screen or perform any other action
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginApp()),
              );
            } else {
              // Handle logout failure
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout Error'),
                    content: Text(
                      'Failed to logout. Please try again later.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
        ListTile(
          title: Text('Setting'),
          trailing: Icon(Icons.settings),
          onTap: () {
            // Perform logout action here
            // _logout();
          },
        ),
      ],
    ),
  );
}

Future<Map<String, dynamic>> _fetchUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('user_id');
    final response = await http.get(
      Uri.parse('http://192.168.1.68:5000/profile'),
      headers: {
        'Authorization':
            'Bearer $storedUserId', // Pass stored user ID in headers
      },
    );
    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      // final userName = userData['name'];
      // final userEmail = userData['email'];
      // final useremotion = userData['Emotion'];
      // print(useremotion);
      // print(userData);
      return userData;
    } else {
      throw Exception('Failed to load user data');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

class MusicInfo {
  final String name;
  final String artist;
  final String album;
  // final String emotion;

  MusicInfo({
    required this.name,
    required this.artist,
    required this.album,
    // required this.emotion,
  });

  factory MusicInfo.fromJson(Map<String, dynamic> json) {
    // print('JSON Data: $json');
    return MusicInfo(
      name: json['name'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      // emotion: json['emotion'] ?? '',
    );
  }
}
