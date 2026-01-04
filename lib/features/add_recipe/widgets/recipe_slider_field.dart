import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';

class RecipeSliderField extends StatelessWidget {
  final String label;
  final String suffix;
  final RxInt value;
  final int min;
  final int max;
  final Function(int) onChanged;

  const RecipeSliderField({
    super.key,
    required this.label,
    required this.suffix,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value.value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min),
            activeColor: AppColors.primary,
            onChanged: (newValue) {
              onChanged(newValue.toInt());
            },
          ),
          Text(
            '${value.value} $suffix',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
      );
    });
  }
}
