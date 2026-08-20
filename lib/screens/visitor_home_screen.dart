//for the Imagefilter.blur widget usage, this library is important
import 'dart:ui';

import 'package:flutter/material.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {

  //A "remote control" key so the right-side button can open the left-side drawer
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  //Controls the Carousel sizing of the Categories Cards (0.35=>35% of screen width)


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
              const UserAccountsDrawerHeader(
                  decoration: BoxDecoration( color: Color(0xFF0F172A)),
                  accountName: Text("Visitor Mode", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                  accountEmail: Text("Unauthenticated Guest Session", style: TextStyle(color: Color(0xFF94A3B8)),),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Color(0xFF38BDF8),
                    child: Icon(Icons.person, color: Colors.white, size: 50,),
                  ),
              ),
              const Spacer(),

              //Bottom: legal warning
              const Padding(
                  padding: EdgeInsets.all(24.0),
                child: Text("WARNING: False reporting carries strict legal penalties under Cameroonian law.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 9, height: 1.5,
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
                          "Register to view live heatmap.",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                        const SizedBox(height: 24),

                        //The Button to Authenticate via OTP
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38BDF8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          onPressed: (){
                            //directs to Twilio OTP Phone Authentication Screen
                            debugPrint("Routing to Authentication...");
                          }, 
                          child: const Text("Create Account", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),

          // LAYER C : Horizontal Caterogies report Bar
          Positioned(
              bottom: 16,
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
                  const SizedBox(height: 12),

                  //Horizontal scrolling of category cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _buildQuickActionBtn(Icons.local_police, 'Police', const Color(0xFF3B82F6)),
                        _buildQuickActionBtn(Icons.local_fire_department, 'FireFighter', const Color(0xFFF97316)),
                        _buildQuickActionBtn(Icons.local_hospital, 'Medical', const Color(0xFF10B981)),
                        _buildQuickActionBtn(Icons.security, 'Military', const Color(0xFF64748B)),
                        _buildQuickActionBtn(Icons.bug_report, 'Demo', const Color(0xFF8B5CF6)), // for Demo
                      ],
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
              icon: const Badge(
                backgroundColor: Color(0xFFFF3B30),
                smallSize: 8,
                child: Icon(Icons.notifications_rounded, size: 28),
              ),
              color: const Color(0xFF94A3B8),
              onPressed: () => debugPrint("Routing to Alerts..."),
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
