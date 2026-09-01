import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/theme/app_colors.dart';
import '../screens/report_incident_form.dart';

class IncidentCategoryCarousel extends StatefulWidget {
  const IncidentCategoryCarousel({super.key});

  @override
  State<IncidentCategoryCarousel> createState() => _IncidentCategoryCarouselState();
}

class _IncidentCategoryCarouselState extends State<IncidentCategoryCarousel> {
  late PageController _pageController;
  int _currentIndex = 2; // Default to the middle card

  // Cleaned data model - removed the heavy background images
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_police, 'label': 'Police', 'color': AppColors.primaryBlue},
    {'icon': Icons.local_fire_department, 'label': 'Firefighter', 'color': AppColors.tacticalOrange},
    {'icon': Icons.local_hospital, 'label': 'Medical', 'color': AppColors.successGreen},
    {'icon': Icons.security, 'label': 'Military', 'color': const Color(0xFF64748B)},
    {'icon': Icons.bug_report, 'label': 'MyDemo', 'color': const Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex, viewportFraction: 0.35);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isFocused = _currentIndex == index;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportIncidentForm(
                    categoryName: _categories[index]['label'],
                    categoryIcon: _categories[index]['icon'],
                    categoryColor: _categories[index]['color'],
                  ),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.symmetric(
                horizontal: 7.0,
                vertical: isFocused ? 10.0 : 25.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  // Strong blur to create the frosted glass effect over the map
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      // Restored pure glassmorphism:
                      // Almost transparent slate when resting, softly tinted with the category color when focused
                      color: isFocused
                          ? _categories[index]['color'].withValues(alpha: 0.2)
                          : AppColors.backgroundBase.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        // Glowing colored border when focused, faint subtle border when resting
                        color: isFocused
                            ? _categories[index]['color'].withValues(alpha: 0.8)
                            : AppColors.borderLight.withValues(alpha: 0.2),
                        width: isFocused ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _categories[index]['icon'],
                            // Muted icons when resting, bright icons when focused
                            color: isFocused
                                ? _categories[index]['color']
                                : AppColors.textMuted.withValues(alpha: 0.6),
                            size: isFocused ? 42 : 28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _categories[index]['label'],
                            style: TextStyle(
                              // Muted text when resting, crisp white text when focused
                              color: isFocused
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary.withValues(alpha: 0.6),
                              fontSize: isFocused ? 14 : 12,
                              fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}