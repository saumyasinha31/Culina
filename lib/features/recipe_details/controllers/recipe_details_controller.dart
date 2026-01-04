import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe/models/recipe_model.dart';
import 'package:food_recipe/features/home_screen/controllers/home_screen_controller.dart';
import 'package:food_recipe/services/pdf_service.dart';

class RecipeDetailsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // recipe data
  final Rx<Recipe?> recipe = Rx<Recipe?>(null);

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isLiked = false.obs;
  final RxBool isSaved = false.obs;
  final RxBool isGeneratingPDF = false.obs;
  final RxString errorMessage = ''.obs;

  // like and save counts
  final RxInt likeCount = 0.obs;
  final RxInt saveCount = 0.obs;

  /// load recipe details
  Future<void> loadRecipeDetails(String recipeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final homeController = Get.find<HomeScreenController>();
      final recipeData = homeController.globalRecipeMap[recipeId];

      if (recipeData == null) {
        errorMessage.value = 'Recipe not found';
        return;
      }

      recipe.value = recipeData;
      likeCount.value = recipeData.likesCount;
      saveCount.value = recipeData.savedCount;

      // check if current user liked this recipe
      await _checkIfLiked(recipeId);
      await _checkIfSaved(recipeId);
    } catch (e) {
      errorMessage.value = 'Error loading recipe: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// check if current user liked this recipe
  Future<void> _checkIfLiked(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final likeDoc = await _firestore
          .collection('recipes')
          .doc(recipeId)
          .collection('likes')
          .doc(user.uid)
          .get();

      isLiked.value = likeDoc.exists;
    } catch (e) {
      debugPrint('Error checking like status: $e');
    }
  }

  /// check if current user saved this recipe
  Future<void> _checkIfSaved(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final savedRecipes = List<String>.from(userDoc.data()?['savedRecipes'] ?? []);

      isSaved.value = savedRecipes.contains(recipeId);
    } catch (e) {
      debugPrint(' Error checking save status: $e');
    }
  }

  /// toggle like on recipe
  Future<void> toggleLike(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Please login to like recipes';
        return;
      }

      final likeRef = _firestore
          .collection('recipes')
          .doc(recipeId)
          .collection('likes')
          .doc(user.uid);

      if (isLiked.value) {
        // unlike
        await likeRef.delete();
        likeCount.value--;
        isLiked.value = false;
        debugPrint(' Recipe unliked');
      } else {
        // like
        await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
        likeCount.value++;
        isLiked.value = true;
        debugPrint(' Recipe liked');
      }

      // update recipe like count
      await _firestore.collection('recipes').doc(recipeId).update({
        'likesCount': likeCount.value,
      });
    } catch (e) {
      errorMessage.value = 'Error updating like: $e';
      debugPrint('Error toggling like: $e');
    }
  }

  /// toggle save on recipe
  Future<void> toggleSave(String recipeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Please login to save recipes';
        return;
      }

      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      final savedRecipes = List<String>.from(userDoc.data()?['savedRecipes'] ?? []);

      if (isSaved.value) {
        // Unsave
        savedRecipes.remove(recipeId);
        saveCount.value--;
        isSaved.value = false;
        debugPrint('Recipe unsaved');
      } else {
        // Save
        savedRecipes.add(recipeId);
        saveCount.value++;
        isSaved.value = true;
        debugPrint('Recipe saved');
      }

      // Update user saved recipes
      await userRef.update({'savedRecipes': savedRecipes});

      // Update recipe save count
      await _firestore.collection('recipes').doc(recipeId).update({
        'savedCount': saveCount.value,
      });
    } catch (e) {
      errorMessage.value = 'Error updating save: $e';
      debugPrint(' Error toggling save: $e');
    }
  }

  /// Check if current user is recipe owner
  bool isRecipeOwner() {
    final user = _auth.currentUser;
    if (user == null || recipe.value == null) return false;
    return recipe.value!.authorId == user.uid;
  }

  /// Delete recipe (only owner can delete)
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      if (!isRecipeOwner()) {
        errorMessage.value = 'You can only delete your own recipes';
        return false;
      }

      isLoading.value = true;

      // delete from Firestore
      await _firestore.collection('recipes').doc(recipeId).delete();

      // remove from global map
      final homeController = Get.find<HomeScreenController>();
      homeController.globalRecipeMap.remove(recipeId);

      // refresh home screen recipes
      await homeController.fetchInitialRecipes();

      debugPrint(' Recipe deleted successfully');
      return true;
    } catch (e) {
      errorMessage.value = 'Error deleting recipe: $e';
      debugPrint(' Error deleting recipe: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// generate PDF of recipe
  Future<void> generatePDF(String recipeId) async {
    try {
      isGeneratingPDF.value = true;
      errorMessage.value = '';

      if (recipe.value == null) {
        errorMessage.value = 'Recipe data not available';
        return;
      }

      final pdfService = PDFService();
      final file = await pdfService.generateRecipePDF(recipe.value!);

      if (file != null) {
        // show success message
        Get.snackbar(
          'Success',
          'PDF saved to Downloads',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        debugPrint('PDF generated successfully: ${file.path}');
      } else {
        errorMessage.value = 'Failed to generate PDF';
        Get.snackbar(
          'Error',
          'Failed to generate PDF',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error generating PDF: $e';
      debugPrint(' Error generating PDF: $e');
      Get.snackbar(
        'Error',
        'Error generating PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingPDF.value = false;
    }
  }

  /// clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
