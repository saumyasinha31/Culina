import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  factory ImageUploadService() {
    return _instance;
  }

  ImageUploadService._internal();

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Error capturing image: $e');
    }
  }

  /// Upload recipe image to Cloudinary
  Future<String> uploadRecipeImage(File imageFile) async {
    return await _cloudinaryService.uploadImage(
      imageFile: imageFile,
      folder: 'food_recipe/recipes',
    );
  }

  /// Upload profile image to Cloudinary
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    return await _cloudinaryService.uploadImage(
      imageFile: imageFile,
      folder: 'food_recipe/profiles',
      publicId: 'profile_$userId',
    );
  }

  /// Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    return await _cloudinaryService.deleteImage(publicId);
  }

  /// Get optimized image URL
  String getOptimizedImageUrl(
    String publicId, {
    int? width,
    int? height,
  }) {
    return _cloudinaryService.getOptimizedImageUrl(
      publicId,
      width: width,
      height: height,
    );
  }
}
