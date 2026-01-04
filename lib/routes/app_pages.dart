import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/auth_ui_screen.dart';
import '../features/onboarding/screens/login_success.dart';
import '../features/home_screen/screens/home_screen.dart';
import '../features/search_recipe/search_screen.dart';
import '../features/add_recipe/screens/add_recipe_screen.dart';
import '../features/user_profile/screens/user_profile_screen.dart';
import '../features/recipe_details/screens/recipe_details_screen.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthUiScreen(),
    ),
    GetPage(
      name: AppRoutes.loginSuccess,
      page: () => const LoginSuccessScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
    ),
    GetPage(
      name: AppRoutes.addRecipe,
      page: () => const AddRecipeScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const UserProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.recipeDetails,
      page: () {
        final recipeId = Get.arguments as String?;
        if (recipeId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Recipe not found'),
            ),
          );
        }
        return RecipeDetailsScreen(recipeId: recipeId);
      },
    ),
  ];

  // Keep the old routes map for compatibility
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (_) => const SplashScreen(),
    AppRoutes.auth: (_) => const AuthUiScreen(),
    AppRoutes.loginSuccess: (_) => const LoginSuccessScreen(),
    AppRoutes.home: (_) => const HomeScreen(),
    AppRoutes.search: (_) => const SearchScreen(),
    AppRoutes.addRecipe: (_) => const AddRecipeScreen(),
    AppRoutes.profile: (_) => const UserProfileScreen(),
  };
}
