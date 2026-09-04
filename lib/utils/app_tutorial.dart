import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AppTutorial {
  static void showFeatureTour({
    required BuildContext context,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      paddingFocus: 10,
      onClickTarget: (target) {},
      onClickOverlay: (target) {},
      onFinish: () {
        onFinish?.call();
      },
      onSkip: () => true,
    ).show(context: context);
  }

  /// Helper to build the dark tutorial card matching your screenshot
  static TargetContent buildTutorialStep({
    required int stepNumber,
    required int totalSteps,
    required String title,
    required String description,
    required VoidCallback onNext,
    VoidCallback? onBack,
    VoidCallback? onSkip,
    ContentAlign align = ContentAlign.bottom,
  }) {
    return TargetContent(
      align: align,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Dark tactical background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STEP COUNTER (e.g. 3 / 4)
              Text(
                '$stepNumber / $totalSteps',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // TITLE & DESCRIPTION
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // NAVIGATION BUTTONS (BACK, SKIP, NEXT)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onBack != null && stepNumber > 1)
                    TextButton(
                      onPressed: onBack,
                      child: Text(
                        'Back',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  Row(
                    children: [
                      if (onSkip != null)
                        TextButton(
                          onPressed: onSkip,
                          child: Text(
                            'Skip',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2A6D), // Glowing Accent Pink
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}