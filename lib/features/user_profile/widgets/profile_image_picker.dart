import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import '../controllers/user_profile_controller.dart';

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({super.key});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  bool _imageLoadError = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();

    return Obx(() {
      final user = controller.currentUser.value;
      final photoUrl = user?.photoUrl ?? '';
      final isUploading = controller.isUploadingProfileImage.value;

      // Reset error state when URL changes
      if (photoUrl.isNotEmpty && photoUrl.startsWith('http') && _imageLoadError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _imageLoadError = false;
            });
          }
        });
      }

      // Show fallback if URL is empty or invalid
      final showFallback = photoUrl.isEmpty || 
          !photoUrl.startsWith('http') || 
          _imageLoadError;

      return GestureDetector(
        onTap: isUploading ? null : () => _showImagePickerOptions(context, controller),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Profile photo container
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: showFallback
                  ? Center(
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    )
                  : ClipOval(
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _imageLoadError = true;
                              });
                            }
                          });
                          return Container(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 70,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            // Edit button overlay
            if (!isUploading)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

            // Loading overlay
            if (isUploading)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showImagePickerOptions(
    BuildContext context,
    UserProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),

            // Gallery option
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text(
                'Pick from Gallery',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.pickProfileImageFromGallery();
              },
            ),

            // Camera option
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primary,
              ),
              title: const Text(
                'Take a Photo',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.pickProfileImageFromCamera();
              },
            ),

            // Remove photo option (if photo exists)
            if (controller.currentUser.value?.photoUrl.isNotEmpty ?? false)
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.removeProfileImage();
                },
              ),

            // Cancel option
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.close,
                color: AppColors.textLight,
              ),
              title: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
