//for the Image filter.blur widget usage, this library is important
import 'dart:ui';
import 'dart:io'; //for network check
import 'dart:convert'; // NEW: For decoding the JSON score response
import 'package:http/http.dart' as http; // NEW: For fetching the updated score

import 'package:flutter/material.dart';
import '/screens/theme/app_colors.dart';
import 'package:sos_defence_project/screens/alerts_screen.dart';
import 'package:sos_defence_project/screens/login_screen.dart';
import 'package:sos_defence_project/screens/signup_screen.dart';
import 'package:sos_defence_project/soswidgets/app_drawer.dart';
import 'package:sos_defence_project/soswidgets/incident_category_carousel.dart';
import 'package:sos_defence_project/soswidgets/live_map_view.dart';
import 'package:sos_defence_project/soswidgets/sos_trigger_overlay.dart';

//for the homepage to save the user's session locally
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '/utils/app_tutorial.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  //A "remote control" key so the right-side button can open the left-side drawer
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  // GlobalKeys for the Interactive App Tutorial spotlight targets
  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey _sosButtonKey = GlobalKey();
  final GlobalKey _mapTabKey = GlobalKey();
  final GlobalKey _alertsTabKey = GlobalKey();

  //for the dynamic appearance of the red badge on the alert icon
  bool _hasUnreadAlerts = true;
  // Role based Access Control for visitor vs citizen
  bool _isAuthenticated = false;
  //to implement user's profile dynamically
  String _currentUserName = "";
  String _currentUserPhone = "";
  int _currentNavIndex = 0; // 0 = Map, 1 = Alerts

  int? _previousTrustScore; // NEW: To track if your score went up!

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();

    // NEW: Check for a score increase as soon as the home screen finishes loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTrustScoreIncrease();
    });
  }

  // --- NEW: REPUTATION REWARD POPUP ---
  Future<void> _checkTrustScoreIncrease() async {
    final token = await ApiService.getToken();
    if (token == null) return; // Stop if they are a visitor (not logged in)

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/user'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        int currentScore = userData['trust_score'] ?? 50; // Default to 50 if null

        if (_previousTrustScore != null && currentScore > _previousTrustScore!) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "🎉 Congratulations! Your report was resolved. Your Trust Score is now $currentScore!",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        _previousTrustScore = currentScore;
      }
    } catch (e) {
      debugPrint("Error checking trust score: $e");
    }
  }

  // --- SILENT AUTO-LOGIN ---
  Future<void> _checkAutoLogin() async {
    final token = await ApiService.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isAuthenticated = true;
        _currentUserName = prefs.getString('user_name') ?? "Citizen";
        _currentUserPhone = prefs.getString('user_phone') ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey, //Attaching the remote control to this screen
      backgroundColor: AppColors.backgroundBase, // Swapped to token
      extendBody: true, //to push the map behind the bottom navbar

      // IF WE ARE ON THE MAP (Index 0), SHOW THIS APP BAR. OTHERWISE, SHOW NULL.
      appBar: _currentNavIndex == 0
          ? AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const Icon(Icons.shield_rounded, color: AppColors.primaryBlue, size: 28),
        title: const Text(
          "SOS Report App",
          style: TextStyle(
            color: AppColors.textPrimary,
            letterSpacing: 1.5,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: _menuButtonKey,
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: (){
              _scafoldKey.currentState?.openDrawer();
            },
          ),
        ],
      )
          : null, // <--- THIS MAKES IT VANISH ON THE ALERTS SCREEN!

      // the LEFT SIDE Drawer menu section
      drawer: AppDrawer(
        isAuthenticated: _isAuthenticated,
        userName: _currentUserName,
        userPhone: _currentUserPhone,
        onLogout: () async {
          // Wipe the token and saved profile data
          await ApiService.clearToken();
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_name');
          await prefs.remove('user_phone');

          setState(() {
            _isAuthenticated = false;
          });
        },
        onStartTutorial: _startAppTutorial, // Launches interactive spotlight tour
      ),
      // the main body of the homepage view
      body: Stack(
        children: [

          // LAYER A : The Map of OpenStreetMap API via Flutter_map
          Positioned.fill(
            child: IndexedStack(
              index: _currentNavIndex,
              children: [
                LiveMapView(isAuthenticated: _isAuthenticated), // Index 0
                AlertsScreen(isAuthenticated: _isAuthenticated), // Index 1
              ],
            ),
          ),

          // LAYER B : The Blur Overlay to prevent visitor from seeing the Map
          if (!_isAuthenticated)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: AppColors.backgroundBase.withValues(alpha: 0.5), // Swapped to token
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.textMuted), // Swapped to token
                        const SizedBox(height: 16),
                        const Text(
                          "Map View Locked",
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold), // Swapped to token
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          "Authenticate to view live heatmap and to Report Incidents.",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14), // Swapped to token
                        ),
                        const SizedBox(height: 32),

                        //The Button to Authenticate or Create Account via OTP
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Log In Button
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryBlue, width: 2), // Swapped to token
                                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: () async {
                                //wait for the log in screen to return its "sticky note" (true or false)
                                final dynamic result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );

                                // if login successful, updating home page state
                                if (result != null && result is Map && result['user'] != null) {
                                  setState(() {
                                    _isAuthenticated = true;
                                    _currentUserName = result['user']['name'];
                                    _currentUserPhone = result['user']['phone_number'];
                                  });
                                }
                              },
                              child: const Text("Log In", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)), // Swapped to token
                            ),
                            const SizedBox(height: 12),

                            //Create Account Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue, // Swapped to token
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: () async {
                                //dynamic which expect to recieve a data package (a map)
                                final dynamic result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                                );

                                //unlocks the map and apply real data if registration was successful
                                if (result != null && result is Map) {
                                  setState(() {
                                    _isAuthenticated = true;
                                    _currentUserName = result["name"];
                                    _currentUserPhone = result["phone"];
                                  });
                                }
                              },
                              child: const Text("Create Account", style: TextStyle(color: AppColors.backgroundBase, fontWeight: FontWeight.bold)), // Swapped to token
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // LAYER 2.5: Dark Gradient Shield (Ensures text/cards are always visible)
          // NEW: Fixed so it disappears on the Alert screen!
          if (_isAuthenticated && _currentNavIndex == 0)
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 250, // Covers the bottom section
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.backgroundBase.withValues(alpha: 0.8), // Swapped to token
                      AppColors.backgroundBase, // Swapped to token
                    ],
                  ),
                ),
              ),
            ),

          // LAYER C : Horizontal Caterogies report Bar
          // NEW: Fixed so it disappears on the Alert screen!
          if (_isAuthenticated && _currentNavIndex == 0)
            const Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              //calling my external widget isolated for incident categories
              child: IncidentCategoryCarousel(),
            ),
        ],
      ),


      // Bottom Navigation Bar Section

      //Asking the SOS floating button to dig itself in the center of the bottom navbar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      //SOS BUTTON breaking out of the bar
      floatingActionButton: _isAuthenticated
          ? Container(
        key: _sosButtonKey,
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.tacticalRed, // Swapped to token
          boxShadow: [
            BoxShadow(
              color: AppColors.tacticalRed.withValues(alpha: 0.4), // Swapped to token
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.sos_rounded, size: 36, color: Colors.white), // Kept pure white for strict SOS contrast
          onPressed: () async {
            // --- NEW OFFLINE CHECK INJECTED HERE ---
            try {
              final result = await InternetAddress.lookup('google.com');
              if (result.isEmpty || result[0].rawAddress.isEmpty) throw Exception();
            } catch (_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("NO NETWORK CONNECTION: Call 117 directly!"),
                  backgroundColor: AppColors.tacticalRed,
                  duration: Duration(seconds: 5),
                ),
              );
              return; // Stops the SOS sequence if offline
            }
            // ---------------------------------------

            // Trigger the full-screen SOS Engine
            final bool? broadcastSuccess = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SOSTriggerOverlay(),
                fullscreenDialog: true, // Makes it slide up like a critical modal
              ),
            );
            // If the sequence finished without being aborted
            if (broadcastSuccess == true) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("CRITICAL SOS BROADCASTED. Emergency services have been notified."),
                  backgroundColor: AppColors.successGreen, // Shows success on the map
                  duration: Duration(seconds: 5),
                ),
              );
            }
          },
        ),
      )
          : null,

      //The bottom navigation bar itself
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surfaceCard,
        height: 60,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // MAP TAB
            IconButton(
              key: _mapTabKey,
              onPressed: () => setState(() => _currentNavIndex = 0),
              icon: Icon(
                  Icons.home_rounded,
                  size: 28,
                  color: _currentNavIndex == 0 ? AppColors.primaryBlue : AppColors.textMuted
              ),
            ),

            const SizedBox(width: 48), // Space for SOS button
            // ALERTS TAB
            IconButton(
              key: _alertsTabKey,
              onPressed: () {
                setState(() {
                  _hasUnreadAlerts = false;
                  _currentNavIndex = 1;
                });

                // Also check for trust score updates when they click the Alerts tab!
                _checkTrustScoreIncrease();
              },
              icon: _hasUnreadAlerts
                  ? const Badge(
                backgroundColor: AppColors.tacticalRed,
                smallSize: 8,
                child: Icon(Icons.notifications_rounded, size: 28),
              )
                  : Icon(
                  Icons.notifications_rounded,
                  size: 28,
                  color: _currentNavIndex == 1 ? AppColors.primaryBlue : AppColors.textMuted
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // INTERACTIVE APP TUTORIAL — Spotlight Feature Tour
  // Triggered from the Drawer menu item
  // -------------------------------------------------------
  void _startAppTutorial() {
    // Only run if authenticated (targets need to be on screen)
    if (!_isAuthenticated) return;

    final targets = <TargetFocus>[
      // TARGET 1: SOS Button
      TargetFocus(
        identify: 'sosButton',
        keyTarget: _sosButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                controller: controller,
                step: 1, total: 4,
                title: 'SOS Emergency Button',
                description: 'Press in a life-threatening emergency. Records 5 seconds of ambient audio and sends your GPS location directly to Police.',
              );
            },
          ),
        ],
      ),

      // TARGET 2: Map Tab
      TargetFocus(
        identify: 'mapTab',
        keyTarget: _mapTabKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                controller: controller,
                step: 2, total: 4,
                title: 'Live Map View',
                description: 'See real-time incidents in your area. Red danger zones indicate active validated emergencies nearby.',
              );
            },
          ),
        ],
      ),

      // TARGET 3: Alerts Tab
      TargetFocus(
        identify: 'alertsTab',
        keyTarget: _alertsTabKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialCard(
                controller: controller,
                step: 3, total: 4,
                title: 'Alerts Feed',
                description: 'View all nearby reported incidents. Confirm or contest alerts within 1km to earn community trust.',
              );
            },
          ),
        ],
      ),

      // TARGET 4: Menu Button
      TargetFocus(
        identify: 'menuButton',
        keyTarget: _menuButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                controller: controller,
                step: 4, total: 4,
                title: 'Side Menu',
                description: 'Access your profile, replay this tutorial, or log out from here.',
              );
            },
          ),
        ],
      ),
    ];

    // Launch the spotlight tour using our centralized tutorial engine
    AppTutorial.showFeatureTour(context: context, targets: targets);
  }

  /// Builds a dark tactical tutorial card with step counter and navigation buttons
  Widget _buildTutorialCard({
    required TutorialCoachMarkController controller,
    required int step,
    required int total,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark tactical background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step counter
          Text(
            '$step / $total',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // Description
          Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => controller.skip(),
                child: Text('Skip', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => controller.next(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2A6D), // Glowing Accent Pink
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

}