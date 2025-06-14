import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DownloadsPage extends StatefulWidget {
  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF67EACB), // <-- Ganti warna background di sini
      appBar: AppBar(title: Text("Downloads")),
      body: Center(
        child: Text(
          "This is the downloads page.",
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
    );
  }
}
