import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final picker = ImagePicker();
  Rx<File?> profileImage = Rx<File?>(null);
  var isLoading = false.obs;
  RxBool isLogin = true.obs;
  RxString errorMessage = ''.obs;

//signup
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';      
      await _authService.signUp(
        name: name,
        email: email,
        password: password,
        profileImage: image,
      );
      
      Get.offAllNamed('/login-success');
    } catch (e) {
      debugPrint('SignUp error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

//login 
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Form data - Email: $email');
      isLoading.value = true;
      errorMessage.value = '';  
      await _authService.login(
        email: email,
        password: password,
      );
      
      debugPrint(' Login successful');
      Get.offAllNamed('/login-success');
    } catch (e) {
      debugPrint('Login error: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

//logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/auth');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

//delete - requires re-authentication
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _authService.deleteAccount(
        email: email,
        password: password,
      );
      Get.offAllNamed('/auth');
    } catch (e) {
      debugPrint('Account deletion error: $e');
      String errorMsg = e.toString();
      
      // Handle specific Firebase errors
      if (errorMsg.contains('wrong-password')) {
        errorMsg = 'Incorrect password. Please try again.';
      } else if (errorMsg.contains('user-not-found')) {
        errorMsg = 'User not found.';
      } else if (errorMsg.contains('invalid-email')) {
        errorMsg = 'Invalid email address.';
      } else if (errorMsg.contains('too-many-requests')) {
        errorMsg = 'Too many attempts. Please try again later.';
      }
      
      // Show error to user
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

 //image picker for profile image 
  Future<void> pickProfileImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
    } else {
      debugPrint('Profile image selection cancelled');
    }
  }
}
