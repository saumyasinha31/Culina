import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_recipe/models/recipe_model.dart';
import 'package:food_recipe/services/recipe_services.dart';
import 'package:food_recipe/services/image_upload_service.dart';
import 'package:food_recipe/features/home_screen/controllers/home_screen_controller.dart';
import 'package:food_recipe/features/user_profile/controllers/user_profile_controller.dart';

class AddRecipeController extends GetxController {
  final RecipeService _recipeService = RecipeService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

   //form
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxString cuisine = 'Italian'.obs;
  final RxString difficulty = 'Easy'.obs;
  final RxInt cookingTime = 30.obs;
  final RxInt servings = 4.obs;
  final RxList<String> ingredients = <String>[].obs;
  final RxList<String> steps = <String>[].obs;

  //recipe image 
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString imageUrl = ''.obs;

  //editing
  final Rx<Recipe?> editingRecipe = Rx<Recipe?>(null);
  final RxBool isEditMode = false.obs;

  //controls ui here
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxString errorMessage = ''.obs;

  // constant now: todo: make enums later 
  static const List<String> cuisineOptions = [
    'Italian',
    'Indian',
    'Chinese',
    'Mexican',
    'Thai',
    'Japanese',
    'Mediterranean',
    'American'
  ];

  static const List<String> difficultyOptions = ['Easy', 'Medium', 'Hard'];

  @override
  void onInit() {
    super.onInit();
    //  if we're in edit mode-> open edit 
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      final recipe = arguments['recipe'] as Recipe?;
      if (recipe != null) {
        _initializeEditMode(recipe);
      }
    }
  }

  ///  edit mode with existing recipe so that user need not to fill recipe again
  void _initializeEditMode(Recipe recipe) {
    isEditMode.value = true;
    editingRecipe.value = recipe;
    
    title.value = recipe.title;
    description.value = recipe.description;
    cuisine.value = recipe.cuisine;
    difficulty.value = recipe.difficulty;
    cookingTime.value = recipe.cookingTime;
    servings.value = recipe.servings;
    ingredients.value = recipe.ingredients;
    steps.value = recipe.steps;
    imageUrl.value = recipe.imageUrl;
  }

  
  Future<void> pickImageFromGallery() async {
    try {
      isUploadingImage.value = true;
      errorMessage.value = '';

      final imageFile = await _imageUploadService.pickImageFromGallery();
      if (imageFile != null) {
        selectedImage.value = imageFile;
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      isUploadingImage.value = true;
      errorMessage.value = '';

      final imageFile = await _imageUploadService.pickImageFromCamera();
      if (imageFile != null) {
        selectedImage.value = imageFile;
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
    } finally {
      isUploadingImage.value = false;
    }
  }

  ///uploadingto  Cloudinary
  Future<bool> uploadImage() async {
    if (selectedImage.value == null) {
      errorMessage.value = 'Please select an image';
      return false;
    }

    try {
      isUploadingImage.value = true;
      errorMessage.value = '';

      final url = await _imageUploadService.uploadRecipeImage(selectedImage.value!);
      imageUrl.value = url;
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to upload image: $e';
      return false;
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Parse ingredients from text (one per line)
  void parseIngredients(String text) {
    ingredients.value = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Parse steps from text (one per line)
  void parseSteps(String text) {
    steps.value = text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Validate form
  bool validateForm() {
    if (title.value.isEmpty) {
      errorMessage.value = 'Please enter recipe title';
      return false;
    }
    if (description.value.isEmpty) {
      errorMessage.value = 'Please enter recipe description';
      return false;
    }
    if (imageUrl.value.isEmpty) {
      errorMessage.value = 'Please upload recipe image';
      return false;
    }
    if (ingredients.isEmpty) {
      errorMessage.value = 'Please add at least one ingredient';
      return false;
    }
    if (steps.isEmpty) {
      errorMessage.value = 'Please add at least one cooking step';
      return false;
    }
    return true;
  }

  /// submit recipe (create or update)
  Future<bool> submitRecipe() async {
    if (!validateForm()) {
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      if (isEditMode.value && editingRecipe.value != null) {
        //update existing recipe
        final updatedRecipe = editingRecipe.value!.copyWith(
          title: title.value,
          description: description.value,
          imageUrl: imageUrl.value,
          cuisine: cuisine.value,
          difficulty: difficulty.value,
          cookingTime: cookingTime.value,
          servings: servings.value,
          ingredients: ingredients,
          steps: steps,
        );

        await _recipeService.updateRecipe(updatedRecipe);

        // update global recipe map
        final homeController = Get.find<HomeScreenController>();
        homeController.globalRecipeMap[editingRecipe.value!.id] = updatedRecipe;
        await homeController.fetchInitialRecipes();
      } else {
        // create new recipe
        final recipe = Recipe(
          id: '', // firestore will generate ID
          title: title.value,
          description: description.value,
          imageUrl: imageUrl.value,
          cuisine: cuisine.value,
          difficulty: difficulty.value,
          cookingTime: cookingTime.value,
          servings: servings.value,
          ingredients: ingredients,
          steps: steps,
          authorId: user.uid,
          authorName: user.email?.split('@')[0] ?? 'Anonymous',
          authorPhotoUrl: '', // TODO:future Get from user profile
          likesCount: 0,
          savedCount: 0,
          createdAt: DateTime.now(),
        );

        // save to Firestore
        await _recipeService.createRecipe(recipe);

        //update global recipe map
        final homeController = Get.find<HomeScreenController>();
        homeController.fetchInitialRecipes();
      }

      // refresh user profile to show new recipe
      try {
        final profileController = Get.find<UserProfileController>();
        await profileController.refreshProfile();
      } catch (e) {
        // profile controller not yet initialized
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to submit recipe: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// reset form
  void resetForm() {
    title.value = '';
    description.value = '';
    cuisine.value = 'Italian';
    difficulty.value = 'Easy';
    cookingTime.value = 30;
    servings.value = 4;
    ingredients.clear();
    steps.clear();
    selectedImage.value = null;
    imageUrl.value = '';
    errorMessage.value = '';
  }

  /// clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
