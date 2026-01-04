import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors/app_colors.dart';
import '../controllers/home_screen_controller.dart';
import '../../onboarding/controllers/auth_controller.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/home_screen_carousal.dart';
import '../widgets/recipe_list.dart';
import '../widgets/welcome_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Register controllers
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }
    if (!Get.isRegistered<HomeScreenController>()) {
      Get.put(HomeScreenController());
    }

    // Welcome dialog
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const WelcomeDialog(),
        );
      }
    });

    // FAB bounce animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const FilterChipsRow(),
            const SizedBox(height: 16),
            const HomeScreenCarousel(),
            const SizedBox(height: 16),
            const Expanded(child: RecipeList()),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          onPressed: () {
            Get.toNamed('/add-recipe');
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
