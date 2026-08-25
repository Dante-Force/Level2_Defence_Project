import 'package:flutter/material.dart';
import 'package:sos_defence_project/screens/login_screen.dart';
import '/screens/theme/app_colors.dart';

class AlertsScreen extends StatefulWidget {
  // we recive the authentication status from the homepage
  final bool isAuthenticated;

  const AlertsScreen({super.key, required this.isAuthenticated});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  //Mock Backend data for the defense MVP
  // the "isNearby" boolean simulates the GPS proximity logic
  final List<Map<String, dynamic>> _mockIncidents = [
    {
      "category": "Medical Emergency",
      //the capital letter 'L' makes this location unfoundable since the rest are in small letter
      "Location": "Nlongkak Roundabout, Yaounde",
      "time": "2 mins ago",
      "icon": Icons.local_hospital_rounded,
      "color": const Color(0xFF10B981), // Medical Green
      "isNearby": true, // User is close enough to cpntest / confirm
    },
    {
      'category': 'Fire Outbreak',
      "location": "Mokolo Market, Sector 4",
      'time': '15 mins ago',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFF97316), // Fire Orange
      'isNearby': false, // Too far away. Buttons will be locked.
    },
    {
      'category': 'Armed Robbery',
      "location": "Bastos, near Embassy",
      'time': '45 mins ago',
      'icon': Icons.local_police_rounded,
      'color': const Color(0xFF3B82F6), // Police Blue
      'isNearby': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Midnight Blue

        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          title: const Text(
            'LIVE REPORTED ALERTS',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      
      // body display lock screen for visitors , else the normal alert scree.
      body: widget.isAuthenticated ? _buildAlertsList() : _buildLockedView(),
    );
  }
  
  //// VIEW 1 / The visitor lock ,Screen
  Widget _buildLockedView(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        
        children: [
          const Icon(Icons.lock_outline_rounded, size: 80, color: Color(0xFF334155),),
          const SizedBox(height: 24),
          const Text(
            "Please log in to view current nearby alerts and history.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8), // Civic Sky Blue
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            ),
            onPressed: (){
              //route to log in. if successful, pop back to the homepage for global state update
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ).then((result) {
                if (result == true) {
                  Navigator.pop(context, true); // pass the success back to the homepage
                }
              });
            },
            child: const Text('Log In', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  ////VIEW 2 : Citizen Alerts screen

  Widget _buildAlertsList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _mockIncidents.length,
        itemBuilder: (context, index) {
          final incident = _mockIncidents[index];
          final bool isNearby = incident["isNearby"];

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // 1. LEFT : Emergency services
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: incident["color"].withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(incident["icon"], color: incident["color"], size: 32),
                ),
                const SizedBox(width: 16),

                //2. MIDDLE : Incident details
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          incident["category"],
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          //to avoid RSOD (Red Screen of Dead) for a missing content that will unfortunately lead to a crash
                          // The "??" tells flutter to print a message if incident["location'] is missing/null
                          incident["location"] ?? "Location unavailable",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              incident["time"],
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),

                //3. RIGHT : Proximity based action buttons
                Column(
                  children: [
                    // Confirm Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isNearby ? const Color(0xFF10B981) : const Color(0xFF334155), // Green if nearby, grey if far
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: isNearby ? () => debugPrint("Incident Confirmed !") : null, // null disables the button
                        child: Text("Confirm", style: TextStyle(color: isNearby ? const Color(0xFF10B981) : const Color(0xFF64748B), fontSize: 12)),
                    ),
                    const SizedBox(height: 8),

                    //CONTEST Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isNearby ? const Color(0xFFFF3B30) : const Color(0xFF334155), // Red if nearby, grey if far
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: isNearby ? () => debugPrint("Incident Contested !") : null,
                      child: Text("Contest", style: TextStyle(color: isNearby ? const Color(0xFFFF3B30) : const Color(0xFF64748B), fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }

}
