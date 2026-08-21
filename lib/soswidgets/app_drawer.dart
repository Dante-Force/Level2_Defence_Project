import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  // Role based Access Control for visitor vs citizen
  final bool isAuthenticated ;
  //to implement user's profile dynamically
  final String userName;
  final String userPhone;

  // This is a "Callback". It allows the Drawer to trigger a function back on the Homepage.
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.isAuthenticated,
    required this.userName,
    required this.userPhone,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                isAuthenticated ? userName : "Visitor Mode",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              accountEmail: Text(
                isAuthenticated ? userPhone : "Unauthenticated Guest Session",
                style: TextStyle(color: Color(0xFF94A3B8)),),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color(0xFF38BDF8),
                child: Icon(Icons.person, color: Colors.white, size: 50,),
              ),
            ),

            // LogOut Button visible if authenticated
            if (isAuthenticated)
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFFF3B30)),
                title: const Text('Log Out', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
                onTap: (){
                  onLogout(); // Triggers the state change function on the Homepage!
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
    );
  }
}
