import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe/features/onboarding/models/user_model.dart';
import 'package:food_recipe/models/recipe_model.dart';
import 'package:food_recipe/features/home_screen/controllers/home_screen_controller.dart';
import 'package:food_recipe/services/image_upload_service.dart';

class UserProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  // User data
  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);

  // Recipe data
  final RxList<String> userRecipeIds = <String>[].obs;
  final RxList<String> savedRecipeIds = <String>[].obs;

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isUploadingProfileImage = false.obs;
  final RxString selectedTab = 'my_recipes'.obs;
  final RxString errorMessage = ''.obs;

  // Stats
  final RxInt recipesPostedCount = 0.obs;
  final RxInt savedRecipesCount = 0.obs;
  final RxInt likesReceivedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    // Listen to auth state changes to refresh profile when user changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserProfile();
      }
    });
  }

  /// Load user profile and recipes
  /// Handles missing user documents gracefully
  Future<void> _loadUserProfile() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        currentUser.value = null;
        return;
      }

      // Fetch user data from Firestore with defensive checks
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      // Handle missing user document
      if (!userDoc.exists) {
    
        // Create default user profile if missing
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.email?.split('@')[0] ?? 'User',
            'email': user.email ?? '',
            'bio': '',
            'photoUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint(' Default user profile created');
        } catch (createError) {
          debugPrint(' Failed to create default profile: $createError');
        }
        
        // Load the newly created profile
        final newUserDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!newUserDoc.exists) {
          throw Exception('Failed to create user profile');
        }
        
        final userData = newUserDoc.data() ?? {};
        currentUser.value = AppUser.fromMap(user.uid, userData);
      } else {
        // User document exists, load it
        final userData = userDoc.data() ?? {};
        debugPrint(' Firestore user data: $userData');
        
        currentUser.value = AppUser.fromMap(user.uid, userData);
        debugPrint(' User profile loaded: ${currentUser.value?.name}');
        debugPrint('User photoUrl: ${currentUser.value?.photoUrl}');
      }

      // Fetch user's recipes
      await _fetchUserRecipes(user.uid);

      // Fetch saved recipes
      await _fetchSavedRecipes(user.uid);

      // Calculate stats
      _calculateStats();
    } catch (e) {
      debugPrint(' Error loading user profile: $e');
      // Don't rethrow - allow app to continue with partial data
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch recipes authored by current user
  /// Uses global recipe map instead of direct Firestore query to avoid index requirements
  Future<void> _fetchUserRecipes(String uid) async {
    try {
      final homeController = Get.find<HomeScreenController>();
      
      // Get all recipes from global map and filter by authorId
      userRecipeIds.clear();
      
      for (final recipeId in homeController.globalRecipeMap.keys) {
        final recipe = homeController.globalRecipeMap[recipeId];
        if (recipe != null && recipe.authorId == uid) {
          userRecipeIds.add(recipeId);
        }
      }
      
      debugPrint(' Loaded ${userRecipeIds.length} user recipes from global map');
      
      // Also try to fetch from Firestore as backup
      try {
        final snapshot = await _firestore
            .collection('recipes')
            .where('authorId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .get();

        for (final doc in snapshot.docs) {
          final recipe = Recipe.fromFirestore(
            doc.id,
            doc.data(),
          );

          // Store in global map for consistency
          homeController.globalRecipeMap[recipe.id] = recipe;

          if (!userRecipeIds.contains(recipe.id)) {
            userRecipeIds.add(recipe.id);
          }
        }
        debugPrint(' Synced ${snapshot.docs.length} recipes from Firestore');
      } catch (firestoreError) {
        // Gracefully handle composite index error
        if (firestoreError.toString().contains('FAILED_PRECONDITION') || 
            firestoreError.toString().contains('requires an index')) {
          debugPrint('Composite index required for user recipes query');
          debugPrint('Using global recipe map instead');
        } else {
          debugPrint('Firestore query error: $firestoreError');
        }
      }
    } catch (e) {
      debugPrint('Error fetching user recipes: $e');
    }
  }

  /// Fetch recipes saved by current user
  Future<void> _fetchSavedRecipes(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final savedIds = List<String>.from(userDoc.data()?['savedRecipes'] ?? []);

      savedRecipeIds.value = savedIds;

      // Fetch recipe details for saved recipes
      for (final recipeId in savedIds) {
        final recipeDoc = await _firestore
            .collection('recipes')
            .doc(recipeId)
            .get();

        if (recipeDoc.exists) {
          final recipe = Recipe.fromFirestore(
            recipeDoc.id,
            recipeDoc.data() ?? {},
          );

          // Store in global map
          final homeController = Get.find<HomeScreenController>();
          homeController.globalRecipeMap[recipe.id] = recipe;
        }
      }
      debugPrint('Loaded ${savedRecipeIds.length} saved recipes');
    } catch (e) {
      debugPrint(' Error fetching saved recipes: $e');
    }
  }

  /// Calculate user stats
  void _calculateStats() {
    recipesPostedCount.value = userRecipeIds.length;
    savedRecipesCount.value = savedRecipeIds.length;

    // Calculate total likes received
    int totalLikes = 0;
    final homeController = Get.find<HomeScreenController>();

    for (final recipeId in userRecipeIds) {
      final recipe = homeController.globalRecipeMap[recipeId];
      if (recipe != null) {
        totalLikes += recipe.likesCount;
      }
    }

    likesReceivedCount.value = totalLikes;
  }

  /// Get recipes for current tab
  List<String> getDisplayedRecipes() {
    if (selectedTab.value == 'my_recipes') {
      return userRecipeIds;
    } else if (selectedTab.value == 'saved_recipes') {
      return savedRecipeIds;
    }
    return userRecipeIds;
  }

  /// Switch between tabs
  void switchTab(String tab) {
    selectedTab.value = tab;
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  /// Pick profile image from gallery
  Future<void> pickProfileImageFromGallery() async {
    try {
      isUploadingProfileImage.value = true;
      errorMessage.value = '';

      final imageFile = await _imageUploadService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadProfileImage(imageFile);
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
      debugPrint(' Error picking image: $e');
    } finally {
      isUploadingProfileImage.value = false;
    }
  }

  /// Pick profile image from camera
  Future<void> pickProfileImageFromCamera() async {
    try {
      isUploadingProfileImage.value = true;
      errorMessage.value = '';

      final imageFile = await _imageUploadService.pickImageFromCamera();
      if (imageFile != null) {
        await _uploadProfileImage(imageFile);
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
      debugPrint(' Error capturing image: $e');
    } finally {
      isUploadingProfileImage.value = false;
    }
  }

  /// Upload profile image to Cloudinary and update Firestore
  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      isUploadingProfileImage.value = true;
      errorMessage.value = '';

      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      // Upload to Cloudinary
      final imageUrl = await _imageUploadService.uploadProfileImage(
        imageFile,
        user.uid,
      );

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local user object - this triggers UI rebuild
      if (currentUser.value != null) {
        final updatedUser = currentUser.value!.copyWith(photoUrl: imageUrl);
        currentUser.value = updatedUser;
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Profile picture updated',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      debugPrint('✅ [Profile] Profile image updated: $imageUrl');
    } catch (e) {
      errorMessage.value = 'Failed to upload image: $e';
      debugPrint('Error uploading profile image: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile picture',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingProfileImage.value = false;
    }
  }

  /// Remove profile image
  Future<void> removeProfileImage() async {
    try {
      isUploadingProfileImage.value = true;
      errorMessage.value = '';

      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      // Update Firestore to remove image
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local user object
      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(photoUrl: '');
      }

      debugPrint('✅ [Profile] Profile image removed');
    } catch (e) {
      errorMessage.value = 'Failed to remove image: $e';
      debugPrint(' Error removing profile image: $e');
    } finally {
      isUploadingProfileImage.value = false;
    }
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
