import 'package:figma/DownloadsPage.dart';
import 'package:figma/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class ProgressLoadingPage extends StatefulWidget {
  @override
  _ProgressLoadingPageState createState() => _ProgressLoadingPageState();
}

class _ProgressLoadingPageState extends State<ProgressLoadingPage> {
  final List<String> stages = ["Embedding", "Attack", "Extraction", "Done!!"];
  int currentStage = 0;

  @override
  void initState() {
    super.initState();
    _startProgressSequence();
  }

  void _startProgressSequence() async {
    for (int i = 0; i < stages.length; i++) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        currentStage = i;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF67EACB),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (stages[currentStage] != "Done!!") ...[
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 5.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stages[currentStage],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ] else ...[
                  Icon(
                    Icons.check_circle_rounded,
                    size: 180,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "DONE!!",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (stages[currentStage] == "Done!!")
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainHomePage(initialIndex: 3)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
