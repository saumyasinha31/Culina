import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_upload_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  /// Update user profile image
  Future<String> updateProfileImage(String userId, File imageFile) async {
    try {
      // Upload image to Cloudinary
      final imageUrl = await _imageUploadService.uploadProfileImage(
        imageFile,
        userId,
      );

      // Update Firestore with new image URL
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return imageUrl;
    } catch (e) {
      throw Exception('Error updating profile image: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  /// Get image upload service
  ImageUploadService get imageUploadService => _imageUploadService;
}
