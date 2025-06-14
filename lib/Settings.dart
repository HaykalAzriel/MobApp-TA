import 'package:figma/Auth.dart';
import 'package:figma/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EACB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF67EACB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          children: [
            _buildSettingTile(
              icon: Icons.person,
              label: "Account",
              onTap: () {},
            ),
            const SizedBox(height: 20),
            _buildSettingTile(
              icon: Icons.help,
              label: "FAQ",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSettingTile(
              icon: Icons.logout,
              label: "Logout",
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () async {
                final auth = AuthService();
                await auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF3BBFBF).withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }
}

// FAQ Page
class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'What is the purpose the app?',
      'answer':
          'It provides protection for the copyright of digital content, particularly images, by embedding invisible watermarks using deep learning techniques...',
    },
    {
      'question': 'How does digital watermarking protect my content?',
      'answer':
          'Watermarking protects your files by hiding a unique mark inside them. If someone edits or shares your content, the mark stays hidden and proves it’s yours.',
    },
    {
      'question': 'What are the supported image formats for watermarking?',
      'answer': 'Upload images in JPG, PNG, or JPEG format. Max size: 10MB.',
    },
    {
      'question': 'Can I choose which watermarking method to use? How?',
      'answer':
          'Yes! Go to Menu > Method, then pick 1 of 4 watermarking options.',
    },
    {
      'question':
          'How does deep learning improve traditional watermarking techniques?',
      'answer':
          'With Deep Learning techniques, your watermark becomes stronger and harder to be removed, even when the image is cropped, compressed, or filtered. AI has trained to recognize watermarks even from damaged files.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF67EACB),
      appBar: AppBar(
        backgroundColor: Color(0xFF67EACB),
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: Colors.black),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'FAQ',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(4),
              color: Color(0xFF67EACB),
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              iconColor: Colors.black,
              collapsedIconColor: Colors.black,
              title: Text(
                faq['question']!,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              children: [
                Text(
                  faq['answer']!,
                  style: GoogleFonts.poppins(color: Colors.black),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
