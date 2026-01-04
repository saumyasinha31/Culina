import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import '../controllers/user_profile_controller.dart';

class ProfileTabs extends StatelessWidget {
  const ProfileTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'My Recipes',
                isSelected: controller.selectedTab.value == 'my_recipes',
                onTap: () => controller.switchTab('my_recipes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TabButton(
                label: 'Saved',
                isSelected: controller.selectedTab.value == 'saved_recipes',
                onTap: () => controller.switchTab('saved_recipes'),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.textLight : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}
