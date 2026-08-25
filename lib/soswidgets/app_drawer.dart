import 'package:flutter/material.dart';
import '/screens/theme/app_colors.dart';

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
      backgroundColor: AppColors.surfaceCard, // Swapped to token
      width: 250,
      child: SafeArea(
        child: Column(
          children: [
            //Top : user info
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.backgroundBase), // Swapped to token
              //Dynamic Account Name:
              accountName: Text(
                isAuthenticated ? userName : "Visitor Mode",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary), // Swapped to token
              ),
              accountEmail: Text(
                isAuthenticated ? userPhone : "Unauthenticated Guest Session",
                style: const TextStyle(color: AppColors.textMuted), // Swapped to token
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: AppColors.primaryBlue, // Swapped to token
                child: Icon(Icons.person, color: AppColors.backgroundBase, size: 50,), // Swapped to contrast color
              ),
            ),

            // LogOut Button visible if authenticated
            if (isAuthenticated)
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.tacticalRed), // Swapped to token
                title: const Text('Log Out', style: TextStyle(color: AppColors.tacticalRed, fontWeight: FontWeight.bold)), // Swapped to token
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
                style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11, height: 1.5, // Swapped to token
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