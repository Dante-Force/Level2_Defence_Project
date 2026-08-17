import 'package:flutter/material.dart';
import 'package:sos_defence_project/screens/onboarding_screen.dart';

void main() {
  runApp(const SOSReportApp());
}

class SOSReportApp extends StatelessWidget {
  const SOSReportApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is my application theme
          scaffoldBackgroundColor:  Colors.black,
          brightness: Brightness.dark,
          fontFamily: 'Roboto',
        ),

      home: const OnboardingScreen(),
    );
  }
}


