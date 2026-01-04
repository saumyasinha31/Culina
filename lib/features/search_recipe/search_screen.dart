import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import './controllers/search_recipe_controller.dart';
import './widgets/search_filter_bar.dart';
import './widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late SearchRecipeController controller;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SearchRecipeController());
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      controller.loadMoreResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Search Recipes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              // Filter bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: const SearchFilterBar(),
              ),

              // Error message
              if (controller.errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.clearError,
                          child: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),

              // Results
              Expanded(
                child: controller.searchResultIds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              controller.searchQuery.value.isEmpty &&
                                      controller.selectedCuisine.value.isEmpty &&
                                      controller.selectedDifficulty.value.isEmpty
                                  ? Icons.search
                                  : Icons.inbox,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchQuery.value.isEmpty &&
                                      controller.selectedCuisine.value.isEmpty &&
                                      controller.selectedDifficulty.value.isEmpty
                                  ? 'Search for recipes'
                                  : 'No recipes found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.searchResultIds.length +
                            (controller.isSearching.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Loading indicator at the end
                          if (index == controller.searchResultIds.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            );
                          }

                          final recipeId =
                              controller.searchResultIds[index];
                          final recipe =
                              controller.getRecipeById(recipeId);

                          if (recipe == null) {
                            return const SizedBox.shrink();
                          }

                          return SearchResultCard(
                            recipe: recipe,
                            onTap: () {
                              // Navigate to recipe details
                              Get.toNamed('/recipe-details', arguments: recipe.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
