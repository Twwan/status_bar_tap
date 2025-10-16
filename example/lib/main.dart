import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:status_bar_tap_example/multiple_controllers_screen.dart';
import 'package:status_bar_tap_example/single_controller_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Main application with three example screens:
/// - StartScreen: Landing page with test selection
/// - TestScreen: Single controller implementation
/// - MultipleControllersScreen: Multiple controllers with split view
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Bar Tap Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartScreen(),
    );
  }
}

/// Landing screen that demonstrates navigation to the test screens
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _multipleControllers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, size: 64, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Status Bar Tap Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const Text(
                    'Mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Single'),
                      Switch(
                        value: _multipleControllers,
                        onChanged: (value) {
                          setState(() => _multipleControllers = value);
                        },
                        activeThumbColor: Colors.blue,
                      ),
                      const Text('Multi'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _multipleControllers
                        ? const MultipleControllersScreen()
                        : const SingleControllerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                _multipleControllers ? 'START MULTI TEST' : 'START SINGLE TEST',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Platform: ${Platform.isIOS ? 'iOS' : Platform.isAndroid ? 'Android' : 'Unknown'}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
