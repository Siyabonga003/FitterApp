import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LeaderboardFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const LeaderboardFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryNeon
                    : (isDark ? AppTheme.darkCard : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryNeon
                      : (isDark ? Colors.white10 : Colors.black12),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.black
                      : (isDark ? Colors.white : AppTheme.textDark),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}