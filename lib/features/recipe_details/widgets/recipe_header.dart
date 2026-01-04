import 'package:flutter/material.dart';
import 'package:food_recipe/models/recipe_model.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';

class RecipeHeader extends StatelessWidget {
  final Recipe recipe;

  const RecipeHeader({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Recipe Image
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            recipe.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
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
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),

        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),

        // Recipe Title
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
