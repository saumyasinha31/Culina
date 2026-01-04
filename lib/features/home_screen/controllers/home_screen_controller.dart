import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_recipe/models/recipe_model.dart';
import 'package:food_recipe/services/recipe_services.dart';

class HomeScreenController extends GetxController {
  final RecipeService _recipeService = RecipeService();

  /// important: i used hashmap here to store recipe id and recipe object to update everywhere to maintain consistency of user interaction across the pages
  final RxMap<String, Recipe> globalRecipeMap = <String, Recipe>{}.obs;

  /// ordered list of recipe IDs for home feed
  final RxList<String> homeFeedIds = <String>[].obs;

  /// pagination 
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  
  final RxBool isLoading = false.obs;
  final RxBool isFetchingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialRecipes();
  }

  /// load initial recipies
  Future<void> fetchInitialRecipes() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      homeFeedIds.clear();
      globalRecipeMap.clear();
      _lastDocument = null;
      _hasMore = true;

      final recipes = await _recipeService.fetchHomeRecipes();

      _upsertRecipes(recipes);
    } finally {
      isLoading.value = false;
    }
  }

  /// inf scroll 
  Future<void> fetchMoreRecipes() async {
    if (!_hasMore || isFetchingMore.value) return;

    try {
      isFetchingMore.value = true;

      final recipes = await _recipeService.fetchHomeRecipes(
        lastDocument: _lastDocument,
      );

      if (recipes.isEmpty) {
        _hasMore = false;
        return;
      }

      _upsertRecipes(recipes);
    } finally {
      isFetchingMore.value = false;
    }
  }

  /// insert/ update recipes into global map
  void _upsertRecipes(List<Recipe> recipes) {
    for (final recipe in recipes) {
      globalRecipeMap[recipe.id] = recipe;
      if (!homeFeedIds.contains(recipe.id)) {
        homeFeedIds.add(recipe.id);
      }
    }
  }

  /// get recipe  anywhere in app by ID
  Recipe? getRecipeById(String recipeId) {
    return globalRecipeMap[recipeId];
  }

  /// update recipe locally (likes, saves, edits)
  void updateRecipeInCache(Recipe updatedRecipe) {
    globalRecipeMap[updatedRecipe.id] = updatedRecipe;
  }

  /// remove recipe everywhere (on delete)
  void removeRecipe(String recipeId) {
    globalRecipeMap.remove(recipeId);
    homeFeedIds.remove(recipeId);
  }

  /// clear state on logout
  void clearAll() {
    globalRecipeMap.clear();
    homeFeedIds.clear();
    _lastDocument = null;
    _hasMore = true;
  }

  /// filter recipes by cuisine, difficulty, or cooking time-> used for filtering in filter chip row in home page
  void filterRecipes({
    String? cuisine,
    String? difficulty,
    int? maxCookingTime,
  }) {
    final filteredIds = <String>[];

    for (final recipeId in globalRecipeMap.keys) {
      final recipe = globalRecipeMap[recipeId];
      if (recipe == null) continue;

      bool matches = true;

      //  cuisine
      if (cuisine != null && recipe.cuisine != cuisine) {
        matches = false;
      }

      // difficulty
      if (difficulty != null && recipe.difficulty != difficulty) {
        matches = false;
      }

      // cooking time
      if (maxCookingTime != null && recipe.cookingTime > maxCookingTime) {
        matches = false;
      }

      if (matches) {
        filteredIds.add(recipeId);
      }
    }

    homeFeedIds.value = filteredIds;
  }

  /// reset filters and show all recipes
  void resetFilters() {
    homeFeedIds.value = globalRecipeMap.keys.toList();
  }
}
