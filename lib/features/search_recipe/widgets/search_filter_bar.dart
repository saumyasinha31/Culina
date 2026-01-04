import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import '../controllers/search_recipe_controller.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchRecipeController>();

    return Obx(() {
      return Column(
        children: [
          // Search field
          TextField(
            onChanged: controller.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: controller.searchQuery.value.isNotEmpty
                  ? GestureDetector(
                      onTap: () => controller.updateSearchQuery(''),
                      child: const Icon(Icons.close, color: AppColors.textLight),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Cuisine filter
                Obx(() {
                  return DropdownButton<String>(
                    value: controller.selectedCuisine.value.isEmpty
                        ? null
                        : controller.selectedCuisine.value,
                    hint: const Text('Cuisine'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All Cuisines'),
                      ),
                      ...SearchRecipeController.cuisineOptions
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                    ],
                    onChanged: controller.updateCuisineFilter,
                    underline: Container(),
                  );
                }),
                const SizedBox(width: 12),

                // Difficulty filter
                Obx(() {
                  return DropdownButton<String>(
                    value: controller.selectedDifficulty.value.isEmpty
                        ? null
                        : controller.selectedDifficulty.value,
                    hint: const Text('Difficulty'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('All Levels'),
                      ),
                      ...SearchRecipeController.difficultyOptions
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                    ],
                    onChanged: controller.updateDifficultyFilter,
                    underline: Container(),
                  );
                }),
                const SizedBox(width: 12),

                // Clear filters button
                if (controller.selectedCuisine.value.isNotEmpty ||
                    controller.selectedDifficulty.value.isNotEmpty)
                  GestureDetector(
                    onTap: controller.clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
