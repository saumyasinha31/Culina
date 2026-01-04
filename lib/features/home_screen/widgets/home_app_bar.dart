import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/colors/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: const Text(
        'Culina',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: AppColors.textDark,
        ),
      ),
      actions: [
        // Star icon - TODO: Future AI recommendations feature
        IconButton(
          icon: const Icon(Icons.star_outline, color: AppColors.textDark),
          onPressed: () {
            // TODO: Implement AI recommendations feature
          },
        ),
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textDark),
          onPressed: () {
            Get.toNamed('/search');
          },
        ),
        GestureDetector(
          onTap: () {
            Get.toNamed('/profile');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                  );
                }

                final userId = userSnapshot.data!.uid;
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, docSnapshot) {
                    if (!docSnapshot.hasData || docSnapshot.data == null || !docSnapshot.data!.exists) {
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      );
                    }

                    try {
                      final data = docSnapshot.data!.data() as Map<String, dynamic>?;
                      final photoUrl = data?['photoUrl'] as String? ?? '';
                      
                      if (photoUrl.isEmpty || !photoUrl.startsWith('http')) {
                        return CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                        );
                      }

                      return CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(photoUrl),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        onBackgroundImageError: (exception, stackTrace) {
                          debugPrint('❌ [HomeAppBar] Profile image load error: $exception');
                        },
                      );
                    } catch (e) {
                      debugPrint('❌ [HomeAppBar] Error reading user data: $e');
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
