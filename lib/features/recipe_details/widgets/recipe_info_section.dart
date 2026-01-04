import 'package:flutter/material.dart';
import 'package:food_recipe/models/recipe_model.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';

class RecipeInfoSection extends StatelessWidget {
  final Recipe recipe;

  const RecipeInfoSection({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            recipe.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.local_dining,
                  label: 'Cuisine',
                  value: recipe.cuisine,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.trending_up,
                  label: 'Difficulty',
                  value: recipe.difficulty,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.schedule,
                  label: 'Time',
                  value: '${recipe.cookingTime}m',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.people,
                  label: 'Servings',
                  value: '${recipe.servings}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
