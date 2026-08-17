import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
 //Controller to manage the  4 slides
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        //locks physics attribute if we are on the legal slide (i.e slide 4), if not, bounce normally
        physics: _currentIndex == 3
          ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        onPageChanged: (index){
          setState(() {
            _currentIndex = index; // to update the state when user swipes
          });
        },
        children: [
          // Slide 1: categories info
          const IncidentCategoriesSlide(),

          // Slide 2: Map and Nearby alerts
          const OnboardingPage(
            icon: Icons.map_rounded,
            title: "LIVE MAP & ALERTS",
            description: "Once authenticated, view real-time incident heatmaps and receive critical safety alerts for your surrounding sector.",
            slideNumber: '02 / 04',
          ),

          // Slide 3: SOS Report Trigger
          const OnboardingPage(
            icon: Icons.sos_rounded,
            title: "INSTANT SOS REPORTING",
            description: "Slide to activate the SOS trigger to initiate a 3-second safety countdown and an AI ambient audio scan for rapid threat evaluation.",
            slideNumber: '03 / 04',
          ),

          // Slide 4: Legal Warning & consent
          const OnboardingPage(
            icon: Icons.gavel_rounded,
            title: "LEGAL WARNING",
            description: "WARNING : False incident reporting is a severe offense under Cameroonian Law. Misusing emergency services carries strict legal penalities!",
            slideNumber: '04 / 04',
          ),
        ],
      ),
    );
  }
}


//Onboarding class layout skeleton for all the Slides except slide 1:
class OnboardingPage extends StatelessWidget {
 final IconData icon;
 final String title;
 final String description;
 final String slideNumber;

 const OnboardingPage({
   super.key,
   required this.icon,
   required this.title,
   required this.description,
   required this.slideNumber,
 });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slide Counter
            Text(
              slideNumber,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),

            ),

            const SizedBox(height: 24),
            Icon(icon, size: 94, color: Colors.white,),
            const SizedBox(height: 32),
            // Header
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 16),
            //Description Text
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.5
              ),
            ),
          ],
        ),
    );
  }
}

// Special class layout skeleton for slide 1 contents
class IncidentCategoriesSlide extends StatelessWidget {
  const IncidentCategoriesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("01 / 02",
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 32),

            // horizontal alignment of icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //medical icon
                Opacity(
                  opacity: 0.4,
                  child: Transform.scale(
                    scale: 0.95,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xE7123357),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.local_hospital_sharp, size: 40, color: Colors.white,),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                //Police Icon (Center Icon)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_police, size: 56, color: Colors.white),
                ),
                const SizedBox(width: 12),

                //Firefighter Icon
                Opacity(
                  opacity: 0.4,
                  child: Transform.scale(
                    scale: 0.95,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xE7123357),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.local_fire_department, size: 40, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),
            const Text("CATEGORIZED INCIDENT REPORTS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text("Direct your Emergency reports instantly to the appropriate public safety services based on the situation encountered !",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              height: 1.5,
            ),
            ),
          ],
        ),
    );
  }
}
