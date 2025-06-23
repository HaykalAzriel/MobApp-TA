// SettingPage.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data =
          await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
      setState(() {
        profile = data;
        isLoading = false;
      });
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(profile: profile!)),
    ).then((_) => _loadProfile());
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF67EACB),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _navigateToEdit,
                  ),
                ],
              ),
            ),

            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profile!['avatar_url'] != null
                      ? NetworkImage(profile!['avatar_url'])
                      : null,
              child:
                  profile!['avatar_url'] == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
            ),

            const SizedBox(height: 12),

            // "Account" title
            const Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),

            const SizedBox(height: 24),

            // Name
            _fieldLabel('Name'),
            _infoTile(Icons.person, profile?['full_name']),

            const SizedBox(height: 12),

            // Username
            _fieldLabel('Username'),
            _infoTile(Icons.badge, profile?['username']),

            const SizedBox(height: 12),

            // Email
            _fieldLabel('Email'),
            _infoTile(Icons.email, profile?['email']),

            const SizedBox(height: 24),

            // Change Password button
            ElevatedButton.icon(
              onPressed: _navigateToChangePassword,
              icon: const Icon(Icons.lock_reset),
              label: const Text('Change Password?'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0004FF),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(250, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0004FF),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF0004FF)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  File? newImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile['full_name']);
    usernameController = TextEditingController(
      text: widget.profile['username'],
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newImage = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    setState(() => isSaving = true);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    String? avatarUrl = widget.profile['avatar_url'];

    if (newImage != null) {
      final path = '$userId.png';
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            path,
            newImage!,
            fileOptions: const FileOptions(upsert: true),
          );
      avatarUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);
    }

    await Supabase.instance.client.from('profiles').upsert({
      'id': userId,
      'full_name': nameController.text.trim(),
      'username': usernameController.text.trim(),
      'avatar_url': avatarUrl,
    });

    setState(() => isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EACB),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: const [BackButton()]),
            ),

            // Avatar + Icon "+"
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        newImage != null
                            ? FileImage(newImage!)
                            : (widget.profile['avatar_url'] != null
                                    ? NetworkImage(widget.profile['avatar_url'])
                                    : null)
                                as ImageProvider?,
                    child:
                        newImage == null &&
                                (widget.profile['avatar_url'] == null ||
                                    widget.profile['avatar_url']
                                        .toString()
                                        .isEmpty)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 24),

            // Name Field
            _inputLabel('Name'),
            _styledInputField(nameController),

            const SizedBox(height: 12),

            // Username Field
            _inputLabel('Username'),
            _styledInputField(usernameController),

            const SizedBox(height: 12),

            // Email Field
            _inputLabel('Email'),
            _styledInputField(
              TextEditingController(text: widget.profile['email']),
              enabled: false,
            ),

            const SizedBox(height: 30),

            // Save / Back
            if (isSaving)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0004FF)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(120, 45),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0004FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(150, 45),
                    ),
                    child: const Text(
                      "Save change",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0004FF),
          ),
        ),
      ),
    );
  }

  Widget _styledInputField(
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0004FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0004FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF0004FF)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isSaving = false;

  void _changePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    setState(() => isSaving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EACB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(alignment: Alignment.centerLeft, child: BackButton()),
              const SizedBox(height: 12),

              // Judul di tengah
              Center(
                child: Column(
                  children: const [
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Change your password",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Input Fields dengan Label
              _inputLabel("Current Password"),
              _styledInputField(currentPasswordController, obscure: true),

              const SizedBox(height: 16),
              _inputLabel("New Password"),
              _styledInputField(newPasswordController, obscure: true),

              const SizedBox(height: 16),
              _inputLabel("Confirm New Password"),
              _styledInputField(confirmPasswordController, obscure: true),

              const SizedBox(height: 24),

              // Save Button
              if (isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0004FF),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              const SizedBox(height: 16),

              // Disclaimer
              const Center(
                child: Text.rich(
                  TextSpan(
                    text: 'By continuing you accept our ',
                    children: [
                      TextSpan(
                        text: 'Term of Service',
                        style: TextStyle(color: Color(0xFF0004FF)),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: Color(0xFF0004FF)),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _styledInputField(
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        hintText:
            "Enter your ${controller == currentPasswordController
                ? 'current'
                : controller == newPasswordController
                ? 'new'
                : 'new'} password",
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
