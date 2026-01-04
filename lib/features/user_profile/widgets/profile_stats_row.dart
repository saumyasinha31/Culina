import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_recipe/utils/colors/app_colors.dart';
import '../controllers/user_profile_controller.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();

    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              count: controller.recipesPostedCount.value,
              label: 'Recipes Posted',
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey.shade300,
            ),
            _StatItem(
              count: controller.savedRecipesCount.value,
              label: 'Saved Recipes',
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey.shade300,
            ),
            _StatItem(
              count: controller.likesReceivedCount.value,
              label: 'Likes Received',
            ),
          ],
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
