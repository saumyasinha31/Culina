import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe/models/recipe_model.dart';
import 'package:food_recipe/services/recipe_services.dart';
import 'package:food_recipe/features/home_screen/controllers/home_screen_controller.dart';

class SearchRecipeController extends GetxController {
  final RecipeService _recipeService = RecipeService();

  // Search state
  final RxString searchQuery = ''.obs;
  final RxList<String> searchResultIds = <String>[].obs;
  final RxMap<String, Recipe> searchResults = <String, Recipe>{}.obs;

  // Filter state
  final RxString selectedCuisine = ''.obs;
  final RxString selectedDifficulty = ''.obs;
  final RxInt maxCookingTime = 120.obs;

  // UI state
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  // Constants
  static const List<String> cuisineOptions = [
    'Italian',
    'Indian',
    'Chinese',
    'Mexican',
    'Thai',
    'Japanese',
    'Mediterranean',
    'American'
  ];

  static const List<String> difficultyOptions = ['Easy', 'Medium', 'Hard'];

  @override
  void onInit() {
    super.onInit();
    // Listen to search query changes
    debounce(
      searchQuery,
      (_) => performSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  /// Perform search with current filters
  Future<void> performSearch() async {
    try {
      isSearching.value = true;
      errorMessage.value = '';
      searchResultIds.clear();
      searchResults.clear();
      _lastDocument = null;
      _hasMore = true;

      if (searchQuery.value.isEmpty &&
          selectedCuisine.value.isEmpty &&
          selectedDifficulty.value.isEmpty) {
        return;
      }

      await _fetchSearchResults();
    } catch (e) {
      errorMessage.value = 'Search failed: $e';
    } finally {
      isSearching.value = false;
    }
  }

  /// Fetch search results from global recipe map
  Future<void> _fetchSearchResults() async {
    try {
      final homeController = Get.find<HomeScreenController>();
      searchResults.clear();
      searchResultIds.clear();

      // Get all recipes from global map
      for (final recipeId in homeController.globalRecipeMap.keys) {
        final recipe = homeController.globalRecipeMap[recipeId];
        if (recipe == null) continue;

        // Apply all filters
        bool matches = true;

        // Text search filter
        if (searchQuery.value.isNotEmpty) {
          if (!_matchesSearchQuery(recipe)) {
            matches = false;
          }
        }

        // Cuisine filter
        if (selectedCuisine.value.isNotEmpty && recipe.cuisine != selectedCuisine.value) {
          matches = false;
        }

        // Difficulty filter
        if (selectedDifficulty.value.isNotEmpty && recipe.difficulty != selectedDifficulty.value) {
          matches = false;
        }

        // Cooking time filter
        if (recipe.cookingTime > maxCookingTime.value) {
          matches = false;
        }

        if (matches) {
          searchResults[recipe.id] = recipe;
          searchResultIds.add(recipe.id);
        }
      }

      // Sort by creation date (newest first)
      final sortedIds = searchResultIds.toList();
      sortedIds.sort((a, b) {
        final recipeA = searchResults[a];
        final recipeB = searchResults[b];
        return recipeB!.createdAt.compareTo(recipeA!.createdAt);
      });
      searchResultIds.value = sortedIds;
    } catch (e) {
      throw Exception('Failed to fetch search results: $e');
    }
  }

  /// Check if recipe matches search query
  bool _matchesSearchQuery(Recipe recipe) {
    final query = searchQuery.value.toLowerCase();
    return recipe.title.toLowerCase().contains(query) ||
        recipe.description.toLowerCase().contains(query) ||
        recipe.cuisine.toLowerCase().contains(query) ||
        recipe.ingredients.any((ing) => ing.toLowerCase().contains(query));
  }

  /// Load more search results (pagination)
  Future<void> loadMoreResults() async {
    // Pagination not needed since we're using in-memory filtering
    // All results are already loaded from global map
    return;
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update cuisine filter
  void updateCuisineFilter(String? cuisine) {
    selectedCuisine.value = cuisine ?? '';
    performSearch();
  }

  /// Update difficulty filter
  void updateDifficultyFilter(String? difficulty) {
    selectedDifficulty.value = difficulty ?? '';
    performSearch();
  }

  /// Update cooking time filter
  void updateCookingTimeFilter(int time) {
    maxCookingTime.value = time;
    performSearch();
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedCuisine.value = '';
    selectedDifficulty.value = '';
    maxCookingTime.value = 120;
    searchResultIds.clear();
    searchResults.clear();
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Get recipe by ID
  Recipe? getRecipeById(String recipeId) {
    return searchResults[recipeId];
  }
}
