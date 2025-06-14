// Refactored AuthService with verifyOTP
import 'package:figma/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      print('Signup error: \$e');
      return false;
    }
  }

  Future<bool> verifyOtp({required String email, required String token}) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: token,
        email: email, // ⬅️ TAMBAHKAN INI
      );

      return response.session != null;
    } catch (e) {
      print('OTP verify error: $e');
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.session != null;
    } catch (e) {
      print('Login error: \$e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('User signed out successfully.');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<bool> resendOtp(String email, String password) async {
  try {
    await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    print("OTP resend triggered.");
    return true;
  } catch (e) {
    print('Resend OTP error: $e');
    return false;
  }
}

}



  // Future<void> logout(BuildContext context) async {
  //   await supabase.auth.signOut();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('isLoggedIn', false);
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginPage()),
  //   );
  // }

  // Future<void> resetPassword(BuildContext context, String email) async {
  //   try {
  //     await supabase.auth.resetPasswordForEmail(email);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Link reset password telah dikirim!")),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Gagal reset password: ${e.toString()}")),
  //     );
  //   }
  // }

