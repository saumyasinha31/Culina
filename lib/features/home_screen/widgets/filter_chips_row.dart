import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors/app_colors.dart';
import '../controllers/home_screen_controller.dart';

class FilterChipsRow extends StatefulWidget {
  const FilterChipsRow({super.key});

  @override
  State<FilterChipsRow> createState() => _FilterChipsRowState();
}

class _FilterChipsRowState extends State<FilterChipsRow> {
  late HomeScreenController _controller;
  int selectedIndex = 0;

  final filters = [
    {'label': 'All', 'type': 'all'},
    {'label': 'Indian', 'type': 'cuisine', 'value': 'Indian'},
    {'label': 'Italian', 'type': 'cuisine', 'value': 'Italian'},
    {'label': 'Chinese', 'type': 'cuisine', 'value': 'Chinese'},
    {'label': 'Easy', 'type': 'difficulty', 'value': 'Easy'},
    {'label': 'Under 30 m', 'type': 'time', 'value': 30},
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeScreenController>();
  }

  void _applyFilter(int index) {
    setState(() {
      selectedIndex = index;
    });

    final filter = filters[index];

    if (filter['type'] == 'all') {
      // Show all recipes
      _controller.resetFilters();
    } else if (filter['type'] == 'cuisine') {
      // Filter by cuisine
      _controller.filterRecipes(cuisine: filter['value'] as String);
    } else if (filter['type'] == 'difficulty') {
      // Filter by difficulty
      _controller.filterRecipes(difficulty: filter['value'] as String);
    } else if (filter['type'] == 'time') {
      // Filter by cooking time
      _controller.filterRecipes(maxCookingTime: filter['value'] as int);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return FilterChip(
            label: Text(
              filters[index]['label'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              _applyFilter(index);
            },
            backgroundColor: Colors.transparent,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }
}
