//for the Image filter.blur widget usage, this library is important
import 'dart:ui';
import '/screens/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:sos_defence_project/screens/alerts_screen.dart';
import 'package:sos_defence_project/screens/login_screen.dart';
import 'package:sos_defence_project/screens/signup_screen.dart';
import 'package:sos_defence_project/soswidgets/app_drawer.dart';
import 'package:sos_defence_project/soswidgets/incident_category_carousel.dart';
import 'package:sos_defence_project/soswidgets/live_map_view.dart';

import 'package:sos_defence_project/soswidgets/sos_trigger_overlay.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {

  //A "remote control" key so the right-side button can open the left-side drawer
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();

  //for the dynamic appearance of the red badge on the alert icon
  bool _hasUnreadAlerts = true;
  // Role based Access Control for visitor vs citizen
  bool _isAuthenticated = false;
  //to implement user's profile dynamically
  String _currentUserName = "";
  String _currentUserPhone = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey, //Attaching the remote control to this screen
      backgroundColor: AppColors.backgroundBase, // Swapped to token
      extendBody: true, //to push the map behind the bottom navbar

      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase, // Swapped to token
        elevation: 0,
        automaticallyImplyLeading: false, // hides the default left side menu icon
        title: const Text(
          "SOS Report App",
          style: TextStyle(
            color: AppColors.textPrimary, // Swapped to token
            letterSpacing: 1.5,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          //right side menu icon
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary), // Swapped to token
            onPressed: (){
              //asking the declared key drawer to slide out
              _scafoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),

      // the LEFT SIDE Drawer menu section

      drawer: AppDrawer(
        isAuthenticated: _isAuthenticated,
        userName: _currentUserName,
        userPhone: _currentUserPhone,
        onLogout: () {
          // This code runs when the user taps "Log Out" inside the AppDrawer file
          setState(() {
            _isAuthenticated = false;
          });
        },
      ),

      // the main body of the homepage view

      body: Stack(
        children: [

          // LAYER A : The Map of OpenStreetMap API via Flutter_map
          Positioned.fill(
            child: LiveMapView(isAuthenticated: _isAuthenticated,),
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
                                if (result != null && result is Map) {
                                  setState(() {
                                    _isAuthenticated = true;
                                    _currentUserName = "verified Citizen"; // name not needed for log in into its account
                                    _currentUserPhone = result['phone'];
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
          if (_isAuthenticated)
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
          if (_isAuthenticated)
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
        width: 75,
        height: 75,
        //==margin: const EdgeInsets.only(top: 32), // Pushes it slightly down into the bar
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
        color: AppColors.backgroundBase, // Swapped to token
        height: 60,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: (){},
              icon: const Icon(Icons.home_rounded, size: 28),
              color: AppColors.primaryBlue, // Swapped to token
            ),
            const SizedBox(width: 48), //empty middle space for SOS button to stand easily

            IconButton(
              icon: _hasUnreadAlerts
                  ? const Badge(
                backgroundColor: AppColors.tacticalRed, // Swapped to token
                smallSize: 8,
                child: Icon(Icons.notifications_rounded, size: 28),
              )
                  : const Icon(Icons.notifications_rounded, size: 28),
              color: AppColors.textMuted, // Swapped to token
              onPressed: () {
                setState(() {
                  _hasUnreadAlerts = false; // clears notif when already read
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlertsScreen(isAuthenticated: _isAuthenticated),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}