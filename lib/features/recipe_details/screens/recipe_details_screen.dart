import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import '../controllers/recipe_details_controller.dart';
import '../widgets/recipe_header.dart';
import '../widgets/recipe_info_section.dart';
import '../widgets/recipe_ingredients_section.dart';
import '../widgets/recipe_steps_section.dart';
import '../widgets/recipe_author_section.dart';
import '../widgets/recipe_action_buttons.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late RecipeDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RecipeDetailsController());
    controller.loadRecipeDetails(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          );
        }

        if (controller.recipe.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Recipe not found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () => Get.back(),
              ),
              actions: [
                if (controller.isRecipeOwner())
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit Recipe'),
                        onTap: () {
                          // Navigate to edit recipe screen
                          Get.toNamed('/add-recipe', arguments: {
                            'recipeId': widget.recipeId,
                            'recipe': controller.recipe.value,
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete Recipe'),
                        onTap: () => _showDeleteConfirmation(),
                      ),
                    ],
                  ),
              ],
            ),

            // Recipe Header (Image)
            SliverToBoxAdapter(
              child: RecipeHeader(recipe: controller.recipe.value!),
            ),

            // Recipe Info (Title, Cuisine, Time, Servings)
            SliverToBoxAdapter(
              child: RecipeInfoSection(recipe: controller.recipe.value!),
            ),

            // Like and Save Buttons
            SliverToBoxAdapter(
              child: RecipeActionButtons(
                controller: controller,
                recipeId: widget.recipeId,
              ),
            ),

            // Author Section
            SliverToBoxAdapter(
              child: RecipeAuthorSection(recipe: controller.recipe.value!),
            ),

            // Ingredients Section
            SliverToBoxAdapter(
              child: RecipeIngredientsSection(
                ingredients: controller.recipe.value!.ingredients,
              ),
            ),

            // Steps Section
            SliverToBoxAdapter(
              child: RecipeStepsSection(
                steps: controller.recipe.value!.steps,
              ),
            ),

            // Download PDF Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  return ElevatedButton.icon(
                    onPressed: controller.isGeneratingPDF.value
                        ? null
                        : () => controller.generatePDF(widget.recipeId),
                    icon: controller.isGeneratingPDF.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(
                      controller.isGeneratingPDF.value
                          ? 'Generating PDF...'
                          : 'Download as PDF',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Delete Recipe',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this recipe? This action cannot be undone.',
          style: TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteRecipe(widget.recipeId);
              if (success) {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Recipe deleted successfully',
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
