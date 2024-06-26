// import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kavir_face/screens/home_screen.dart';

// List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emotion Recognition App',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
