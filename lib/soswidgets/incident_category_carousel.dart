import 'package:flutter/material.dart';
import 'dart:ui';
import '/screens/theme/app_colors.dart';

class IncidentCategoryCarousel extends StatefulWidget {
  const IncidentCategoryCarousel({super.key});

  @override
  State<IncidentCategoryCarousel> createState() => _IncidentCategoryCarouselState();
}

class _IncidentCategoryCarouselState extends State<IncidentCategoryCarousel> {
  //Controls the Carousel sizing of the Categories Cards (0.35=>35% of screen width)
  final PageController _categoryController = PageController(viewportFraction: 0.35, initialPage: 1);
  int _focusedIndex = 1; // tracks which card is in the center

  //define the data for our catego cards
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_police, 'label': 'Police', 'color': const Color(0xFF3B82F6)},
    {'icon': Icons.local_fire_department, 'label': 'FireFighter', 'color': const Color(0xFFF97316)},
    {'icon': Icons.local_hospital, 'label': 'Medical', 'color': const Color(0xFF10B981)},
    {'icon': Icons.security, 'label': 'Military', 'color': const Color(0xFF64748B)},
    {'icon': Icons.bug_report, 'label': 'MyDemo', 'color': const Color(0xFF8B5CF6)},
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Report Incidents",
            style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 25, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _categoryController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _focusedIndex = index; //update state as the user swipes
              });
            },
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              //logic for the fade/scale effect
              bool isFocused = _focusedIndex == index;

              return GestureDetector(
                onTap: () {
                  if (!isFocused) {
                    _categoryController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut
                    );
                  } else {
                    debugPrint("${_categories[index]['label']} Report Incident Triggered!");
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(
                    horizontal: isFocused ? 4.0 : 12.0,
                    vertical: isFocused ? 0 : 16.0,
                  ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // True Frosted Glass Blur
                          //=============================================
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isFocused
                                    ? _categories[index]['color']
                                    : Colors.white.withValues(alpha: 0.1),
                                width: isFocused ? 2 : 1,
                              ),
                            ),
                            // WE UPGRADED TO A STACK TO LAYER THE WATERMARK BEHIND THE TEXT
                            child: Stack(
                              children: [
                                // 1. THE FADED WATERMARK BACKGROUND
                                Positioned(
                                  right: -15, // Pushes it slightly off the edge for style
                                  bottom: -15, // Pushes it slightly down
                                  child: Icon(
                                    _categories[index]['icon'],
                                    color: Colors.white.withValues(alpha: 0.08), // Highly transparent
                                    size: isFocused ? 110 : 80, // Massive symbolic size
                                  ),
                                ),

                                // 2. THE MAIN FOREGROUND CONTENT
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _categories[index]['icon'],
                                        color: _categories[index]['color'],
                                        size: isFocused ? 42 : 28,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _categories[index]['label'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isFocused ? 14 : 12,
                                          fontWeight: FontWeight.bold,
                                          shadows: const [
                                            Shadow(color: Colors.black, blurRadius: 4)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //=========================
              ),
                    ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
