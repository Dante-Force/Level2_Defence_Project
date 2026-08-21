//for the Image filter.blur widget usage, this library is important
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sos_defence_project/screens/alerts_screen.dart';
import 'package:sos_defence_project/screens/login_screen.dart';
import 'package:sos_defence_project/screens/signup_screen.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {

  //A "remote control" key so the right-side button can open the left-side drawer
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  //Controls the Carousel sizing of the Categories Cards (0.35=>35% of screen width)
  final PageController _categoryController = PageController(viewportFraction: 0.35, initialPage: 1);
  int _focusedIndex = 1; // tracks which card is in the center
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
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        automaticallyImplyLeading: false, // hides the default left side menu icon
        title: const Text(
          "SOS Report App",
          style: TextStyle(
            color: Colors.white, letterSpacing: 1.5, fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          //right side menu icon
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: (){
              //asking the declared key drawer to slide out
              _scafoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),

      // the left side Drawer menu section
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E293B),
        width: 250,
        child: SafeArea(
          child: Column(
            children: [
              //Top : user info
               UserAccountsDrawerHeader(
                  decoration: BoxDecoration( color: Color(0xFF0F172A)),
                  //Dynamic Account Name:
                  accountName: Text(
                    _isAuthenticated ? _currentUserName : "Visitor Mode",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  accountEmail: Text(
                    _isAuthenticated ? _currentUserPhone : "Unauthenticated Guest Session",
                    style: TextStyle(color: Color(0xFF94A3B8)),),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Color(0xFF38BDF8),
                    child: Icon(Icons.person, color: Colors.white, size: 50,),
                  ),
              ),
              
              // LogOut Button visible if authenticated
              if (_isAuthenticated)
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Color(0xFFFF3B30)),
                  title: const Text('Log Out', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
                  onTap: (){
                    //update state to lock the map
                    setState(() {
                      _isAuthenticated = false;
                    });
                    Navigator.pop(context);// closes the drawer automatically
                  },
                ),
              const Spacer(),

              //Bottom: legal warning
              const Padding(
                  padding: EdgeInsets.all(24.0),
                child: Text("WARNING: False reporting carries strict legal penalties under Cameroonian law.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11, height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // the main body of the homepage view

      body: Stack(
        children: [

          // LAYER A : the map Placeholder
          Positioned.fill(
              child: Container(
                color: const Color(0xFF0B1120),
                child: const Center(
                  child: Icon(Icons.map_outlined, size: 100, color: Color(0xFF1E293B)),
                ),
              ),
          ),

          // LAYER B : The Blur Overlay to prevent visitor from seeing the Map
          if (!_isAuthenticated)
          Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 64, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 16),
                        const Text(
                          "Map View Locked",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          "Authenticate to view live heatmap and to Report Incidents.",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                        const SizedBox(height: 32),

                        //The Button to Authenticate or Create Account via OTP
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            //Log In Button
                            OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF38BDF8), width: 2),
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
                                child:const Text("Log In", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),

                            //Create Account Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38BDF8),
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
                              child: const Text("Create Account", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),

          // LAYER C : Horizontal Caterogies report Bar
          if (_isAuthenticated)
          Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Report Incidents",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: PageView.builder(
                      controller: _categoryController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _focusedIndex = index; //update state as the user swipes
                        });
                      },
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        //define the data for our catego cards
                        final List<Map<String, dynamic>> categories = [
                          {"icon": Icons.local_police, 'label': 'Police', 'color': const Color(0xFF3B82F6)},
                          {"icon": Icons.local_fire_department, 'label': 'FireFighter', 'color': const Color(0xFFF97316)},
                          {"icon": Icons.local_hospital, 'label': 'Medical', 'color': const Color(0xFF10B981)},
                          {"icon": Icons.security, 'label': 'Military', 'color': const Color(0xFF64748B)},
                          {"icon": Icons.bug_report, 'label': 'MyDemo', 'color': const Color(0xFF8B5CF6)},
                        ];

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
                              debugPrint("${categories[index]["label"]} Report Incident Triggered !");
                            }
                          },
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            margin: EdgeInsets.symmetric(
                              horizontal: isFocused ? 4.0 : 12.0,
                              vertical: isFocused ? 0 : 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                //only the focused card gets a colored glowing border to pop forward
                                color: isFocused ? categories[index]["color"].withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.05),
                                width:  isFocused ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(
                                  categories[index]["icon"],
                                  color: categories[index]["color"],
                                  size: isFocused ? 40 : 20,
                                ),
                                const SizedBox(height: 12),

                                Text(
                                  categories[index]["label"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
                                    fontSize: isFocused ? 14 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),


      // Bottom Navigation Bar Section

      //Asking the SOS floating button to dig itself in the center of the bottom navbar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      //SOS BUTTON breaking out of the bar
      floatingActionButton: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.only(top: 32), // Pushes it slightly down into the bar
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFF3B30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.sos_rounded, size: 36, color: Colors.white),
          onPressed: () {
            debugPrint("Massive SOS Triggered!");
          },
        ),
      ),

      //The bottom navigation bar itself
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0F172A),
        height: 60,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: (){},
              icon: const Icon(Icons.home_rounded, size: 28),
              color: const Color(0xFF38BDF8),
            ),
            const SizedBox(width: 48), //empty middle space for SOS button to stand easily

            IconButton(
              icon: _hasUnreadAlerts
                  ? const Badge(
                      backgroundColor: Color(0xFFFF3B30),
                      smallSize: 8,
                      child: Icon(Icons.notifications_rounded, size: 28),
                    )
                  : const Icon(Icons.notifications_rounded, size: 28),
              color: const Color(0xFF94A3B8),
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

  //// WIDGET BUILDER CREATION function for the Report Incident Cards
 Widget _buildQuickActionBtn(IconData icon, String label, Color iconColor) {
    return Container(
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      padding: EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,),
          ),
        ],
      ),
    );
 }
}
