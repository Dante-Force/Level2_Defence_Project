import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_defence_project/screens/login_screen.dart';
import '/screens/theme/app_colors.dart';

class AlertsScreen extends StatefulWidget {
  final bool isAuthenticated;
  const AlertsScreen({super.key, required this.isAuthenticated});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> _incidents = [];
  bool _isLoading = true;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      _fetchLiveAlerts();
    }
  }

  Future<void> _fetchLiveAlerts() async {
    setState(() => _isLoading = true);
    try {
      // 1. Get exact GPS location to calculate distance
      _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high));

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // 2. Fetch live and history incidents from your Laravel API
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/api/incidents?latitude=${_currentPosition!
                .latitude}&longitude=${_currentPosition!.longitude}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _incidents = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching alerts: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBase,
        elevation: 0,
        title: const Text(
          'LIVE REPORTED ALERTS',
          style: TextStyle(color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: widget.isAuthenticated ? _buildAlertsList() : _buildLockedView(),
    );
  }

  Widget _buildLockedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 80,
              color: AppColors.borderLight),
          const SizedBox(height: 24),
          const Text(
            "Please log in to view current nearby alerts and history.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textPrimary, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ).then((result) {
                if (result == true) Navigator.pop(context, true);
              });
            },
            child: const Text('Log In', style: TextStyle(
                color: AppColors.backgroundBase,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (_incidents.isEmpty) {
      return const Center(
        child: Text("No alerts in your area. Stay safe!",
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _incidents.length,
        itemBuilder: (context, index) {
          final incident = _incidents[index];

// Parse PostGIS coordinates (Magellan returns GeoJSON format: [longitude, latitude])
          final coords = incident['location']['coordinates'];
          double incidentLat = coords[1];
          double incidentLng = coords[0];

// Calculate distance in meters
          double distanceInMeters = Geolocator.distanceBetween(
            _currentPosition!.latitude, _currentPosition!.longitude,
            incidentLat, incidentLng,
          );

// LOGIC: Enable buttons ONLY if < 1km (1000m) AND incident is still ACTIVE
          bool isNearby = distanceInMeters <= 1000;
          bool isClosed = (incident['status'] == 'RESOLVED' ||
              incident['status'] == 'FALSE_ALERT');

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
// THE MISSING BRACKET WAS HERE:
              border: Border.all(
                color: isClosed
                    ? AppColors.borderLight
                    : AppColors.tacticalRed.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
// 1. LEFT: Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
// AND HERE:
                    color: isClosed
                        ? AppColors.textMuted.withValues(alpha: 0.2)
                        : AppColors.tacticalOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      isClosed ? Icons.history : Icons.warning_amber_rounded,
                      color: isClosed ? AppColors.textMuted : AppColors
                          .tacticalOrange,
                      size: 32
                  ),
                ),
                const SizedBox(width: 16),

// 2. MIDDLE: Incident Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident["category"],
                        style: TextStyle(
                            color: isClosed ? AppColors.textMuted : AppColors
                                .textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        incident["description"] ?? "No description provided",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: isClosed ? AppColors.textMuted : AppColors
                                  .primaryBlue, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${(distanceInMeters / 1000).toStringAsFixed(
                                1)} km away",
                            style: const TextStyle(color: AppColors.textMuted,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

// 3. RIGHT: Action Buttons OR Closed Badge
                if (isClosed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      incident['status'] == 'RESOLVED'
                          ? "RESOLVED"
                          : "FALSE ALERT",
                      style: const TextStyle(color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Column(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isNearby
                              ? AppColors.successGreen
                              : AppColors.borderLight),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: isNearby ? () =>
                            debugPrint("Vote Confirm Triggered") : null,
                        child: Text("Confirm", style: TextStyle(
                            color: isNearby ? AppColors.successGreen : AppColors
                                .textMuted, fontSize: 12)),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isNearby
                              ? AppColors.tacticalRed
                              : AppColors.borderLight),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: isNearby ? () =>
                            debugPrint("Vote Contest Triggered") : null,
                        child: Text("Contest", style: TextStyle(
                            color: isNearby ? AppColors.tacticalRed : AppColors
                                .textMuted, fontSize: 12)),
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