// Halaman 1: Isi nama lengkap
import 'dart:io';

import 'package:figma/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NamePage extends StatefulWidget {
  final String userId;
  const NamePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController fullNameController = TextEditingController();

  void _continueToUsername() {
    final name = fullNameController.text.trim();
    if (name.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => UsernamePage(
              userId: widget.userId,
              fullName: fullNameController.text.trim(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, size: 20),
            ),
            const SizedBox(height: 50),
            const Text(
              "What is your name?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text("Full name"),
            const SizedBox(height: 16),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                hintText: 'Insert your name here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _continueToUsername,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0004FF),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white),
              ),
            ),

            _buildTermsText(),
          ],
        ),
      ),
    );
  }
}

// Halaman 2: Buat Username
class UsernamePage extends StatefulWidget {
  final String userId;
  final String fullName;

  const UsernamePage({Key? key, required this.userId, required this.fullName})
    : super(key: key);

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController usernameController = TextEditingController();

  void _continueToPhotoPage() async {
    final username = usernameController.text.trim();
    if (username.isEmpty) return;

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': widget.userId,
        'full_name': widget.fullName,
        'username': username,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProfilePhotoPage(
                userId: widget.userId,
                fullName: widget.fullName,
                username: username,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // penting untuk rata kiri
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                "Create Username",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Optional subtitle (kalau ingin ditambahkan nanti)
              // const Text("Pick a unique username to identify yourself."),
              const SizedBox(height: 24),

              // Label
              const Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // Input field
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Button
              ElevatedButton(
                onPressed: _continueToPhotoPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0004FF),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              _buildTermsText(),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman 3: Upload Foto Profil
class ProfilePhotoPage extends StatefulWidget {
  final String userId;
  final String fullName;
  final String username;

  const ProfilePhotoPage({
    super.key,
    required this.userId,
    required this.fullName,
    required this.username,
  });

  @override
  State<ProfilePhotoPage> createState() => _ProfilePhotoPageState();
}

class _ProfilePhotoPageState extends State<ProfilePhotoPage> {
  File? selectedImage;
  bool uploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih foto terlebih dahulu.")),
      );
      return;
    }

    setState(() => uploading = true);
    try {
      final filePath = '${widget.userId}.png';

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            filePath,
            selectedImage!,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      await Supabase.instance.client.from('profiles').upsert({
        'id': widget.userId,
        'full_name': widget.fullName,
        'username': widget.username,
        'avatar_url': imageUrl,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainHomePage(),
        ), // Ganti sesuai halaman utama
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengunggah foto: $e")));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> _submitWithPhoto() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih foto terlebih dahulu.")),
      );
      return;
    }

    setState(() => uploading = true);
    try {
      final filePath = '${widget.userId}.png';

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            filePath,
            selectedImage!,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      await Supabase.instance.client.from('profiles').upsert({
        'id': widget.userId,
        'full_name': widget.fullName,
        'username': widget.username,
        'avatar_url': imageUrl,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainHomePage(),
        ), // ganti dengan halaman utama kamu
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengunggah foto: $e")));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> _submitWithoutPhoto() async {
    setState(() => uploading = true);
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': widget.userId,
        'full_name': widget.fullName,
        'username': widget.username,
        'avatar_url': '',
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan profil: $e")));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Add a profile photo",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Click the profile avatars to insert your photo"),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    selectedImage != null ? FileImage(selectedImage!) : null,
                child:
                    selectedImage == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: uploading ? null : _submitWithPhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0004FF),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  uploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        "Add Photo",
                        style: TextStyle(color: Colors.white),
                      ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: uploading ? null : _submitWithoutPhoto,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0004FF)),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Later",
                style: TextStyle(color: Color(0xFF0004FF)),
              ),
            ),

            _buildTermsText(),
          ],
        ),
      ),
    );
  }
}

Widget _buildTermsText() {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Center(
      // Tambahkan ini
      child: RichText(
        textAlign:
            TextAlign.center, // Tambahkan ini agar teks multiline tetap rapi
        text: const TextSpan(
          text: 'By continuing you accept our ',
          style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12),
          children: [
            TextSpan(
              text: 'Term of Service',
              style: TextStyle(color: Color(0xFF0004FF)),
            ),
            TextSpan(text: ' and ', style: TextStyle(color: Color(0xFF7C7C7C))),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(color: Color(0xFF0004FF)),
            ),
          ],
        ),
      ),
    ),
  );
}
