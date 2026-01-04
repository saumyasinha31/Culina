import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  
  // Cloudinary configuration - loaded from .env
  late final String cloudName;
  late final String uploadPreset;

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal() {
    cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  }

  /// Upload image to Cloudinary using unsigned upload
  Future<String> uploadImage({
    required File imageFile,
    required String folder,
    String? publicId,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      // Create multipart request
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder;

      // Add public_id if provided
      if (publicId != null) {
        request.fields['public_id'] = publicId;
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Cloudinary upload failed with status ${response.statusCode}');
      }

      // Parse response
      final data = jsonDecode(responseBody);
      final secureUrl = data['secure_url'] as String?;

      if (secureUrl == null) {
        throw Exception('No secure_url in Cloudinary response');
      }

      return secureUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// delete image from cloudinary (requires api key - not implemented for unsigned uploads)
  Future<bool> deleteImage(String publicId) async {
    try {
      // unsigned uploads cannot delete images
      // this would require api key authentication
      return false;
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }

  /// get optimized image url with transformations
  /// note: if the url is already a complete cloudinary url, return it as-is
  String getOptimizedImageUrl(
    String publicId, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    try {
      // if it's already a complete url, return it
      if (publicId.startsWith('http')) {
        return publicId;
      }

      // build url with transformations
      String url = 'https://res.cloudinary.com/$cloudName/image/upload/';

      // add transformations
      final transformations = <String>[];
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      if (quality.isNotEmpty) transformations.add('q_$quality');

      if (transformations.isNotEmpty) {
        url += '${transformations.join(',')}/';
      }

      url += publicId;
      return url;
    } catch (e) {
      return publicId; // return original if transformation fails
    }
  }
}
