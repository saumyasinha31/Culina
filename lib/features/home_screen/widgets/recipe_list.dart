import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recipe_card.dart';
import 'empty_state.dart';
import '../../../utils/colors/app_colors.dart';
import '../controllers/home_screen_controller.dart';

class RecipeList extends StatelessWidget {
  const RecipeList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeScreenController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        );
      }

      if (controller.homeFeedIds.isEmpty) {
        return const EmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchInitialRecipes(),
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),
            const Text(
              'Recipe Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: controller.homeFeedIds.length,
              itemBuilder: (context, index) {
                final recipeId = controller.homeFeedIds[index];
                // Double-check recipe exists before rendering card
                if (controller.getRecipeById(recipeId) == null) {
                  return const SizedBox.shrink();
                }
                return RecipeCard(
                  recipeId: recipeId,
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
