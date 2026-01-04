import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import '../controllers/add_recipe_controller.dart';
import '../widgets/recipe_image_picker.dart';
import '../widgets/recipe_form_field.dart';
import '../widgets/recipe_dropdown_field.dart';
import '../widgets/recipe_slider_field.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  late AddRecipeController controller;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController ingredientsController;
  late TextEditingController stepsController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddRecipeController());
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    ingredientsController = TextEditingController();
    stepsController = TextEditingController();

    // prefill fields if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isEditMode.value) {
        titleController.text = controller.title.value;
        descriptionController.text = controller.description.value;
        ingredientsController.text = controller.ingredients.join('\n');
        stepsController.text = controller.steps.join('\n');
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    ingredientsController.dispose();
    stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Obx(() {
          return Text(
            controller.isEditMode.value ? 'Edit Recipe' : 'Add Recipe',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: AppColors.textDark,
            ),
          );
        }),
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // error message
                    if (controller.errorMessage.value.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.clearError,
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    if (controller.errorMessage.value.isNotEmpty)
                      const SizedBox(height: 16),

                    // image picker
                    const RecipeImagePicker(),
                    const SizedBox(height: 24),

                    
                    RecipeFormField(
                      label: 'Recipe Title',
                      hintText: 'Enter recipe title',
                      controller: titleController,
                      onChanged: (value) => controller.title.value = value,
                    ),
                    const SizedBox(height: 16),

                    
                    RecipeFormField(
                      label: 'Description',
                      hintText: 'Describe your recipe',
                      controller: descriptionController,
                      maxLines: 3,
                      onChanged: (value) => controller.description.value = value,
                    ),
                    const SizedBox(height: 16),

                    // cuisine & difficulty
                    Row(
                      children: [
                        Expanded(
                          child: RecipeDropdownField(
                            label: 'Cuisine',
                            value: controller.cuisine.value,
                            items: AddRecipeController.cuisineOptions,
                            onChanged: (value) {
                              if (value != null) {
                                controller.cuisine.value = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RecipeDropdownField(
                            label: 'Difficulty',
                            value: controller.difficulty.value,
                            items: AddRecipeController.difficultyOptions,
                            onChanged: (value) {
                              if (value != null) {
                                controller.difficulty.value = value;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // cooking time & Servings
                    Row(
                      children: [
                        Expanded(
                          child: RecipeSliderField(
                            label: 'Cooking Time',
                            suffix: 'min',
                            value: controller.cookingTime,
                            min: 5,
                            max: 120,
                            onChanged: (value) =>
                                controller.cookingTime.value = value,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RecipeSliderField(
                            label: 'Servings',
                            suffix: 'servings',
                            value: controller.servings,
                            min: 1,
                            max: 12,
                            onChanged: (value) =>
                                controller.servings.value = value,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ingredients
                    RecipeFormField(
                      label: 'Ingredients',
                      hintText: 'Enter ingredients (one per line)',
                      controller: ingredientsController,
                      maxLines: 4,
                      onChanged: (value) => controller.parseIngredients(value),
                    ),
                    const SizedBox(height: 16),

                    // steps
                    RecipeFormField(
                      label: 'Cooking Steps',
                      hintText: 'Enter cooking steps (one per line)',
                      controller: stepsController,
                      maxLines: 5,
                      onChanged: (value) => controller.parseSteps(value),
                    ),
                    const SizedBox(height: 24),

                    // submit button -> \t\o\do use ds here
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => _submitRecipe(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                controller.isEditMode.value
                                    ? 'Update Recipe'
                                    : 'Publish Recipe',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // loading overlay
              if (controller.isUploadingImage.value)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _submitRecipe() async {
    // upload image first if a new image was selected
    if (controller.selectedImage.value != null &&
        controller.imageUrl.value.isEmpty) {
      final imageUploaded = await controller.uploadImage();
      if (!imageUploaded) {
        return;
      }
    }

    // submit recipe
    final success = await controller.submitRecipe();
    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        controller.isEditMode.value
            ? 'Recipe updated successfully! ✏️'
            : 'Recipe published successfully! 🎉',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    }
  }
}
