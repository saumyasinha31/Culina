import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // generate gravatar url from email when image is not there
  String _generateGravatarUrl(String email) {
    final emailLower = email.toLowerCase().trim();
    final hash = md5.convert(emailLower.codeUnits).toString();
    final gravatarUrl = 'https://www.gravatar.com/avatar/$hash?d=identicon&s=200';
    return gravatarUrl;
  }

  // email validation regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // password validation - minimum 8 characters, at least one uppercase, one lowercase, one number
  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    File? profileImage,
  }) async {
    // Validate email
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format. Please enter a valid email.');
    }
    // Validate password
    if (!_isValidPassword(password)) {
      throw Exception(
        'Password must be at least 8 characters with uppercase, lowercase, and numbers.',
      );
    }

    try {
      // disable recaptcha for testing
      _auth.setSettings(appVerificationDisabledForTesting: true);
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Signup timeout. Please check your internet connection.');
        },
      );
      
      // gravatar 
      final gravatarUrl = _generateGravatarUrl(email);

      try {
        final userData = {
          'name': name,
          'email': email,
          'bio': '',
          'photoUrl': gravatarUrl,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(credential.user!.uid).set(userData).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Firestore save timeout.');
          },
        );
      } catch (e) {
        // continue even if firestore fails - user is already created in auth
      }
      
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // validate email
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format. Please enter a valid email.');
    }

    try {
      // disable recaptcha for testing
      _auth.setSettings(appVerificationDisabledForTesting: true);
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Login timeout. Please check your internet connection.');
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// re-authenticate user before sensitive operations
  /// required for account deletion due to firebase security requirements
  Future<void> _reauthenticateUser(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  /// delete user account with re-authentication
  /// requires email and password for security verification
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    try {
      // step 1: re-authenticate user (required by firebase for account deletion)
      await _reauthenticateUser(email, password);

      // step 2: delete user data from firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // step 3: delete firebase auth user
      await user.delete();
    } catch (e) {
      rethrow;
    }
  }
}
