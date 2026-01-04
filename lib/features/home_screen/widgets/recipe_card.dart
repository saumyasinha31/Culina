import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors/app_colors.dart';
import '../controllers/home_screen_controller.dart';

class RecipeCard extends StatelessWidget {
  final String recipeId;

  const RecipeCard({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeScreenController>();

    return Obx(() {
      final recipe = controller.getRecipeById(recipeId);
      
      // Return empty container if recipe is deleted or not found
      if (recipe == null) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () {
          // Navigate to recipe details
          Get.toNamed('/recipe-details', arguments: recipeId);
        },
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // image
              AspectRatio(
                aspectRatio: 1.1,
                child: _buildRecipeImage(recipe.imageUrl),
              ),

              // content_> future ll use typography and need to wrap everything will flexible to avoid any overflow
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.cuisine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.schedule,
                          size: 10,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${recipe.cookingTime}m',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 12,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          recipe.likesCount.toString(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.bookmark_border,
                          size: 12,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          recipe.savedCount.toString(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Build recipe image with proper error handling
  Widget _buildRecipeImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(
              Icons.restaurant,
              size: 40,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
