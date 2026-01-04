import 'package:flutter/material.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';

class RecipeIngredientsSection extends StatefulWidget {
  final List<String> ingredients;

  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
  });

  @override
  State<RecipeIngredientsSection> createState() =>
      _RecipeIngredientsSectionState();
}

class _RecipeIngredientsSectionState extends State<RecipeIngredientsSection> {
  late List<bool> checkedItems;

  @override
  void initState() {
    super.initState();
    checkedItems = List<bool>.filled(widget.ingredients.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.shopping_basket,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.ingredients.length} items',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ingredients List
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.ingredients.length,
              itemBuilder: (context, index) {
                return _IngredientItem(
                  ingredient: widget.ingredients[index],
                  isChecked: checkedItems[index],
                  onChanged: (value) {
                    setState(() {
                      checkedItems[index] = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final String ingredient;
  final bool isChecked;
  final Function(bool?) onChanged;

  const _IngredientItem({
    required this.ingredient,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isChecked,
      onChanged: onChanged,
      title: Text(
        ingredient,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textDark,
          decoration: isChecked ? TextDecoration.lineThrough : null,
          decorationColor: AppColors.textLight,
        ),
      ),
      activeColor: AppColors.primary,
      checkColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      dense: true,
    );
  }
}
