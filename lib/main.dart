import 'dart:io';

import 'package:figma/Auth.dart';
import 'package:figma/DownloadsPage.dart';
import 'package:figma/HostPage.dart';
import 'package:figma/MethodsPage.dart';
import 'package:figma/WatermarkPage.dart';
import 'package:figma/image_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jvwjuubdgeiciaqiefxg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2d2p1dWJkZ2VpY2lhcWllZnhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk3NTM0NjcsImV4cCI6MjA2NTMyOTQ2N30.P0YnlzHkEya7qp_KytWEg0Vjh7392bkxg7v1Ml6BNgg',
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (_) => ImageState(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

// HALAMAN AWAL
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IncPic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Splash Screen with Loading Animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int stage = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => stage = 1);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => stage = 2);
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB1E3E4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: stage >= 1 ? 1.0 : 0.0,
              child: Text(
                "IncPic",
                style: GoogleFonts.racingSansOne(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: stage >= 2 ? 1.0 : 0.0,
              child: const Text(
                "Your Image Your Identity",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}

// WELCOME PAGE
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 231,
              height: 203,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFB1E3E4),
                borderRadius: BorderRadius.circular(
                  30,
                ), // Bisa diganti sesuai kebutuhan, misal 20 atau 40
              ),
              child: Text(
                "IncPic",
                style: GoogleFonts.racingSansOne(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Create your InPic account",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "InPic lets you securely embed, extract, and analyze watermarks with ease",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7C7C7C)),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0004FF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.zero, // hilangkan padding default
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ikon di kiri
                  Positioned(
                    left: 16,
                    child: ClipOval(
                      child: Image.asset(
                        'lib/images/google.png',
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Teks di tengah
                  const Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            OutlinedButton(
              child: const Text("Log In"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0004FF),
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF0004FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                text: 'By continuing you accept our ',
                style: const TextStyle(color: Color(0xFF7C7C7C)),
                children: [
                  TextSpan(
                    text: 'Term of Service',
                    style: const TextStyle(color: Color(0xFF0004FF)),
                    // Add onTap gesture here if needed
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(color: Color(0xFF0004FF)),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

//  SIGN UP PAGE

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    final success = await AuthService().signUpWithEmail(email, password);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP sent to your email')));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(email: email, password: password),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed, try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: Column(
        children: [
          // AppBar manual
          Padding(
            padding: const EdgeInsets.only(
              top: 50,
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.purpleAccent.withOpacity(0),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
              ],
            ),
          ),
          // Progress Indicator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: LinearProgressIndicator(
              value: 0.2, // misalnya 20% selesai
              backgroundColor: Colors.white,
              color: Color(0xFF0004FF),
              minHeight: 6,
            ),
          ),
          // Formulir pendaftaran
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Enter your email to access InPic securely",
                      style: TextStyle(fontSize: 16, color: Color(0xFF7C7C7C)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    const SizedBox(height: 24),
                    const Text(
                      "Email",
                      style: TextStyle(
                        color: Color(0xFF0004FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Enter your email Address',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF0004FF),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    const Text(
                      "Password",
                      style: TextStyle(
                        color: Color(0xFF0004FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Enter your Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),

                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF0004FF),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    const Text(
                      "Confirm Password",
                      style: TextStyle(
                        color: Color(0xFF0004FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Your Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF0004FF),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        child:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Create Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0004FF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'By continuing you accept our ',
                          style: TextStyle(color: Color(0xFF7C7C7C)),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// LOGIN PAGE
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  void handleLogin() async {
    final success = await authService.signInWithEmail(
      emailController.text.trim(),
      passwordController.text,
    );

    if (success) {
      // Navigasi ke HomePage atau halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainHomePage(),
        ), // ganti HomePage sesuai dengan app Anda
      );
    } else {
      // Tampilkan notifikasi gagal login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login gagal. Periksa kembali email dan password."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF67EFC4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol back
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(height: 30),
              // Title
              const Center(
                child: Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Enter your email  and password to acces InPic securely",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF7C7C7C)),
                ),
              ),
              const SizedBox(height: 32),

              // Email
              const Text(
                "Email",
                style: TextStyle(
                  color: Color(0xFF0004FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0004FF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0004FF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              const Text(
                "Password",
                style: TextStyle(
                  color: Color(0xFF0004FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0004FF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0004FF)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Log In
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0004FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: (handleLogin),
                  child: const Text("Log In", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),

              // Terms and Privacy
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'By continuing you accept our ',
                    style: TextStyle(color: Color(0xFF7C7C7C)),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String? password;

  const VerifyEmailPage({Key? key, required this.email, required this.password})
    : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  void _verifyOTP() async {
    setState(() {
      _isVerifying = true;
    });

    final success = await _authService.verifyOtp(
      email: widget.email,
      token: _otpController.text.trim(),
    );

    setState(() {
      _isVerifying = false;
    });

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP salah atau sudah kadaluarsa.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar + progress
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.1),
              child: LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.white,
                color: Color(0xFF0004FF),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Verify Your Email",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We’ve sent a verification code to your email.\nEnter the code below to continue.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Color(0xFF7C7C7C),
              ),
            ),
            const SizedBox(height: 32),

            // OTP input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                onChanged: (_) {},
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  fieldHeight: 60,
                  fieldWidth: 40,
                  activeColor: Colors.black,
                  selectedColor: Colors.black,
                  inactiveColor: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't get a code?",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _isVerifying = true;
                    });

                    final success = await _authService.resendOtp(
                      widget.email,
                      widget.password ?? '',
                    );

                    setState(() {
                      _isVerifying = false;
                    });

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "OTP telah dikirim ulang ke ${widget.email}",
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal mengirim ulang OTP.")),
                      );
                    }
                  },

                  child: Text(
                    "Resend",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF0004FF),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Verify Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0004FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child:
                      _isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Verify",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Terms and Privacy
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: RichText(
        text: TextSpan(
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
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF8A94A6),
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Email verified successfully.\nWelcome!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class MainHomePage extends StatefulWidget {
  final int initialIndex;
  const MainHomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static final List<Widget> _pages = <Widget>[
    HostPage(),
    WatermarkPage(),
    MethodsPage(),
    DownloadsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: Color(0xFF67EACB), // latar belakang hijau
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.upload_file, 'Host'),
              _buildNavItem(1, Icons.image, 'Watermark'),
              _buildNavItem(2, Icons.tune, 'Methods'),
              _buildNavItem(3, Icons.download, 'Downloads'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.black : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
