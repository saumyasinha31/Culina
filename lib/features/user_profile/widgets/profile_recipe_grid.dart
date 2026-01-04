import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import 'package:food_recipe/features/home_screen/controllers/home_screen_controller.dart';
import '../controllers/user_profile_controller.dart';

class ProfileRecipeGrid extends StatelessWidget {
  const ProfileRecipeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();
    final homeController = Get.find<HomeScreenController>();

    return Obx(() {
      final recipeIds = controller.getDisplayedRecipes();

      if (recipeIds.isEmpty) {
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 56,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.selectedTab.value == 'my_recipes'
                      ? 'No recipes yet'
                      : 'No saved recipes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.selectedTab.value == 'my_recipes'
                      ? 'Start sharing your favorite recipes!'
                      : 'Save recipes to view them here',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: recipeIds.length,
          itemBuilder: (context, index) {
            final recipeId = recipeIds[index];
            final recipe = homeController.globalRecipeMap[recipeId];

            if (recipe == null) {
              return const SizedBox.shrink();
            }

            return _RecipeGridCard(recipe: recipe);
          },
        ),
      );
    });
  }
}

class _RecipeGridCard extends StatelessWidget {
  final dynamic recipe;

  const _RecipeGridCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/recipe-details', arguments: recipe.id);
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
            // Image
            AspectRatio(
              aspectRatio: 1.1,
              child: Image.network(
                recipe.imageUrl,
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
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // Content
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
  }
}
