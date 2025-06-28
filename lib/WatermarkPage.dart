import 'dart:io';

import 'package:figma/Settings.dart';
import 'package:figma/image_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class WatermarkPage extends StatefulWidget {
  final String sessionId; // Kirim ID sesi dari page sebelumnya

  const WatermarkPage({Key? key, required this.sessionId}) : super(key: key);
  @override
  _WatermarkPageState createState() => _WatermarkPageState();
}

class _WatermarkPageState extends State<WatermarkPage> {
  File? _image;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: await _showImageSourceDialog(),
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Provider.of<ImageState>(
        context,
        listen: false,
      ).setWatermarkImage(File(pickedFile.path));
      await _uploadWatermarkImage(_image!);
    }
  }

  Future<void> _uploadWatermarkImage(File imagefile) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _image == null) return;

    setState(() => _uploading = true);

    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      // Upload ke storage bucket watermark-image
      final storageResponse = await Supabase.instance.client.storage
          .from('watermark-image')
          .upload('public/$fileName', _image!);

      final publicUrl = Supabase.instance.client.storage
          .from('watermark-image')
          .getPublicUrl('public/$fileName');

      // Cari session terakhir milik user
      final sessionResponse =
          await Supabase.instance.client
              .from('sessions')
              .select()
              .eq('user_id', user.id)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle(); // Aman dari null

      if (sessionResponse != null && sessionResponse['id'] != null) {
        final sessionId = sessionResponse['id'] as String;

        // Update kolom watermark_url
        await Supabase.instance.client
            .from('sessions')
            .update({'watermark_url': publicUrl})
            .eq('id', sessionId);
      } else {
        // Jika tidak ada sesi sebelumnya, buat yang baru
        await Supabase.instance.client.from('sessions').insert({
          'user_id': user.id,
          'watermark_url': publicUrl,
          'host_url': '', // agar tidak null
          'status': 'pending',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Watermark image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<ImageSource> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Choose image source'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                    child: const Text('Camera'),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.pop(context, ImageSource.gallery),
                    child: const Text('Gallery'),
                  ),
                ],
              ),
        ) ??
        ImageSource.gallery;
  }

  @override
  Widget build(BuildContext context) {
    final _image = Provider.of<ImageState>(context).watermarkImage;
    return FutureBuilder(
      future:
          Supabase.instance.client
              .from('profiles')
              .select('username, avatar_url')
              .eq('id', Supabase.instance.client.auth.currentUser!.id)
              .single(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data as Map<String, dynamic>;
        final username = profile['username'] ?? 'User';
        final avatarUrl = profile['avatar_url'] ?? '';

        return Scaffold(
          backgroundColor: Color(0xFF67EACB),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage:
                            avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                        child:
                            avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hi, Welcome\n$username',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: LinearProgressIndicator(
                    value: 0.2, // misalnya 20% selesai
                    backgroundColor: Colors.white,
                    color: Color(0xFF0004FF),
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 30),
                Column(
                  children: [
                    Text(
                      'IncPic',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // atur jarak antar teks, makin kecil makin rapat
                    Text(
                      'Your image, your identity',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Poppins',
                        color: Color(
                          0xFF7C7C7C,
                        ), // jika tidak ingin pakai GoogleFonts
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text(
                  'Upload Watermark Image',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'This is the image what will be embedded as a watermark',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7C7C7C)),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // Image preview / picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child:
                        _image != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 90,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Browse Watermark Image',
                                  style: TextStyle(
                                    color: Color(0xFF0004FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Accepted formats: .jpg, .jpeg, .png\nMax file size: 20MB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                  ),
                ),
                if (_uploading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomIcon(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
