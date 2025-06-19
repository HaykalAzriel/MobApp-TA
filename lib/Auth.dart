// Refactored AuthService with verifyOTP
import 'package:figma/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> setLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', value);
  }

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

      if (response.session != null) {
        await setLoginStatus(true);
        print('User logged in successfully.');
        return true;
      } else {
        print('Login failed: No session found.');
        return false;
      }
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
      await _supabase.auth.signUp(email: email, password: password);

      print("OTP resend triggered.");
      return true;
    } catch (e) {
      print('Resend OTP error: $e');
      return false;
    }
  }

  // Kirim OTP ke email untuk reset password
  Future<void> sendResetToken(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception("Gagal mengirim token: $e");
    }
  }

  // Verifikasi token dan simpan session sementara
  Future<void> verifyToken({required String email, required String otp}) async {
    try {
      await _supabase.auth.verifyOTP(
        type: OtpType.recovery,
        token: otp,
        email: email,
      );
    } catch (e) {
      throw Exception("OTP tidak valid: $e");
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception("Gagal update password: $e");
    }
  }
}







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

