import 'package:figma/Auth.dart';
import 'package:figma/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool loading = false;

  void sendOTP() async {
    setState(() => loading = true);
    try {
      await AuthService().sendResetToken(emailController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyResetTokenPage(email: emailController.text),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => errorDialog(context, e.toString()),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                  "Reset Password",
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
                  "Enter your email to receive a reset Token",
                  style: TextStyle(fontSize: 14, color: Color(0xFF7C7C7C)),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Email",
                style: TextStyle(
                  color: Color(0xFF0004FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0004FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: loading ? null : sendOTP,
                  child:
                      loading
                          ? CircularProgressIndicator()
                          : const Text(
                            "Send",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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

class VerifyResetTokenPage extends StatefulWidget {
  final String email;
  const VerifyResetTokenPage({super.key, required this.email});

  @override
  State<VerifyResetTokenPage> createState() => _VerifyResetTokenPageState();
}

class _VerifyResetTokenPageState extends State<VerifyResetTokenPage> {
  final TextEditingController otpController = TextEditingController();
  bool verifying = false;

  void verifyOTP() async {
    setState(() => verifying = true);
    try {
      await AuthService().verifyToken(
        email: widget.email,
        otp: otpController.text,
      );
      _showSuccessDialog(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => errorDialog(context, e.toString()),
      );
    }
    setState(() => verifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Column(
            children: [
              // Tombol kembali
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 5),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: FractionallySizedBox(
                  widthFactor: 2,
                  child: LinearProgressIndicator(
                    value: 0.5,
                    color: const Color(0xFF0004FF),
                    backgroundColor: Colors.white,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                "Verify Your Email",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We’ve sent a verification code to your email.\nEnter the code below to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const SizedBox(height: 32),

              // Kolom OTP
              PinCodeTextField(
                appContext: context,
                controller: otpController,
                length: 6,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                autoFocus: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.black,
                  selectedColor: Colors.black,
                  inactiveColor: Colors.black26,
                ),
                onChanged: (value) {},
              ),

              const SizedBox(height: 10),

              // Resend
              // TextButton(
              //   onPressed: resendCode,
              //   child: const Text(
              //     "Didn't get a code? Resend",
              //     style: TextStyle(color: Colors.blue),
              //   ),
              // ),
              const SizedBox(height: 30),

              // Tombol Verify
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0004FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: verifying ? null : verifyOTP,
                  child:
                      verifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Verify",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),

              const SizedBox(height: 12),

              // Terms & Privacy
              _buildTermsText(),
            ],
          ),
        ),
      ),
    );
  }
}

// Move this function outside the class
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

void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
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
                            builder: (_) => const NewPasswordPage(),
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

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});
  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController pass1 = TextEditingController();
  final TextEditingController pass2 = TextEditingController();
  bool saving = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void resetPassword() async {
    if (pass1.text != pass2.text) {
      showDialog(
        context: context,
        builder: (_) => errorDialog(context, "Passwords do not match."),
      );
      return;
    }
    setState(() => saving = true);
    try {
      await AuthService().updatePassword(pass1.text);
      showSuccessDialog(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => errorDialog(context, e.toString()),
      );
    }
    setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67EFC4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol kembali
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
              ),
              const SizedBox(height: 20),

              // Judul
              const Center(
                child: Text(
                  "Reset your password",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Enter your new password to access InPic\nsecurely",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF7C7C7C)),
                ),
              ),
              const SizedBox(height: 32),

              // Password
              const Text(
                "Password",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: pass1,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: "Enter your new password",
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
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              const Text(
                "Confirm Password",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: pass2,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: "Confirm your password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saving ? null : resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0004FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child:
                      saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Reset",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF0004FF),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, color: Color(0xFF0004FF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms and Privacy
              Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'By continuing you accept our ',
                    style: TextStyle(color: Color(0xFF7C7C7C), fontSize: 12),
                    children: [
                      TextSpan(
                        text: 'Term of Service',
                        style: TextStyle(color: Color(0xFF0004FF)),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(color: Color(0xFF7C7C7C)),
                      ),
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

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
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
                  'Reset Password Successfully.',
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

Widget errorDialog(BuildContext context, String message) {
  return AlertDialog(
    title: const Text("Error"),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("OK"),
      ),
    ],
  );
}
