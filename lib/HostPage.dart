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

class HostPage extends StatefulWidget {
  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  File? _Image;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: await _showImageSourceDialog(),
    );

    if (pickedFile != null) {
      setState(() {
        _Image = File(pickedFile.path);
      });

      Provider.of<ImageState>(
        context,
        listen: false,
      ).setHostImage(File(pickedFile.path));
      await _uploadHostImage(_Image!);
    }
  }

  Future<void> _uploadHostImage(File imageFile) async {
    setState(() {
      _uploading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User not logged in';

      final fileExt = imageFile.path.split('.').last;
      final fileName = const Uuid().v4();
      final filePath = '${user.id}/$fileName.$fileExt';

      // Upload ke bucket storage 'host-image'
      final storageRes = await Supabase.instance.client.storage
          .from('host-image')
          .upload(filePath, imageFile);

      final publicUrl = Supabase.instance.client.storage
          .from('host-image')
          .getPublicUrl(filePath);

      // Tambahkan ke tabel sessions
      await Supabase.instance.client.from('sessions').insert({
        'user_id': user.id,
        'host_url': publicUrl,

        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Host image uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      setState(() {
        _uploading = false;
      });
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
    final _Image = Provider.of<ImageState>(context).hostImage;
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
                  'Upload Host Image',
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
                    'This is the image where your watermark will be embedded.',
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
                        _Image != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _Image!,
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
                                  'Browse Host Image',
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
