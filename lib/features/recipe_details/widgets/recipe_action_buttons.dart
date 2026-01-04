import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import '../controllers/recipe_details_controller.dart';

class RecipeActionButtons extends StatelessWidget {
  final RecipeDetailsController controller;
  final String recipeId;

  const RecipeActionButtons({
    super.key,
    required this.controller,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Like Button
          Expanded(
            child: Obx(() {
              return ElevatedButton.icon(
                onPressed: () => controller.toggleLike(recipeId),
                icon: Icon(
                  controller.isLiked.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: Text(
                  '${controller.likeCount.value}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isLiked.value
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: controller.isLiked.value
                      ? Colors.white
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),

          // Save Button
          Expanded(
            child: Obx(() {
              return ElevatedButton.icon(
                onPressed: () => controller.toggleSave(recipeId),
                icon: Icon(
                  controller.isSaved.value
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                label: Text(
                  '${controller.saveCount.value}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isSaved.value
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: controller.isSaved.value
                      ? Colors.white
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
