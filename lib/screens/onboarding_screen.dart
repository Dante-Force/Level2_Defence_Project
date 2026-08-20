import 'package:flutter/material.dart';
import 'package:sos_defence_project/screens/visitor_home_screen.dart';

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
      // Deep Midnight Blue (#0F172A), my app base color theme 1
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: Column(
          children: [

            Expanded( // Top Bar the 4 slides
              child: PageView(
                controller: _pageController,
                //locks physics attribute if we are on the legal slide (i.e slide 4), if not, bounce normally
                physics:  const BouncingScrollPhysics(),
                onPageChanged: (index){
                  setState(() {
                    _currentIndex = index; // to update the state when user swipes
                  });
                },

                children: const [
                  // Slide 1: categories info
                   OnboardingPage(
                     icon: Icons.category_rounded,
                     title: "Categorized Incident Reports",
                     description: "Direct your reports instantly to the appropriate public safety services based on the situation encountered !",
                   ),

                  // Slide 2: Map and Nearby alerts
                   OnboardingPage(
                    icon: Icons.map_rounded,
                    title: "LIVE MAP & ALERTS",
                    description: "Once authenticated, view real-time incident heatmaps and receive critical safety alerts for your surrounding sector.",

                  ),

                  // Slide 3: SOS Report Trigger
                   OnboardingPage(
                    icon: Icons.sos_rounded,
                    title: "INSTANT SOS REPORTING",
                    description: "Slide to activate the SOS trigger to initiate a 3-second safety countdown and an AI ambient audio scan for rapid threat evaluation.",

                  ),

                  // Slide 4: Legal Warning & consent
                  LegalWarningSlide(),
                ],
              ),
            ),

            //standard dot indicators sliding
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index){
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentIndex == index ? 24.0 : 8.0,
                      height: 8.0,
                      decoration:  BoxDecoration(
                        color: _currentIndex == index ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    );
                  }),
                ),
            ),

            //Bottom action Area: to display the "I accept" button only on slide 4 and "Continue" for the rest of slides
            Padding(
                  padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentIndex == 3 ? Colors.red : const Color(0xFF38BDF8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                      ),
                      onPressed: (){
                        if (_currentIndex == 3) {
                          // To do navigation to the visitor homepage
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (
                                context) => const VisitorHomeScreen()),
                          );
                        } else{
                          // advance to next slide if not yet on legal page
                          _pageController.nextPage(
                             duration: const Duration(milliseconds: 300),
                             curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentIndex == 3 ? "I ACCEPT" : "Continue",
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 16, letterSpacing: 1.2,
                           fontWeight: FontWeight.bold,
                         ),
                      ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


//Onboarding class layout skeleton for all the Slides :
class OnboardingPage extends StatelessWidget {
 final IconData icon;
 final String title;
 final String description;

 const OnboardingPage({
   super.key,
   required this.icon,
   required this.title,
   required this.description,
 });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Slide Counter
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 64,
                color: const Color(0xFF38BDF8),
              ),
            ),

            const SizedBox(height: 48),
           //Heder text design
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, fontSize: 24, letterSpacing: 1.1,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            // Description Text Design
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
    );
  }
}

// Legal WARNING slide additional style
class LegalWarningSlide extends StatelessWidget {
  const LegalWarningSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Gavel icon with subtle red/ember warning aura
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.6), width: 2,
                ),
              ),
              child: const Icon(
                Icons.gavel_rounded,
                size: 65,
                color: Color(0xFFFF3B30),
              ),
            ),

            const SizedBox(height: 36),
            const Text(
              "Legal Warning & Compliance",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "WARNING: False reporting or malicious pranks directed at emergency services carry severe legal penalties under Cameroonian law. Ensure all generated Incident Report represent valid threats.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14, height: 1.5,
              ),
            ),
          ],
        ),
    );
  }
}


