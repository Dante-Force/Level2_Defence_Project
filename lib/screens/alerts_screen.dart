import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_defence_project/screens/login_screen.dart';
import '/screens/theme/app_colors.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  final bool isAuthenticated;
  const AlertsScreen({super.key, required this.isAuthenticated});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> _incidents = [];
  bool _isLoading = false;
  Position? _currentPosition;

  // Track local user vote per incident: incidentId -> isValid (true = confirm, false = contest)
  final Map<int, bool> _votedIncidents = {};
  // Track voting in-flight state PER INCIDENT so one card never blocks another
  final Set<int> _votingIncidentIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      _fetchLiveAlerts();
    }
  }

  @override
  void didUpdateWidget(covariant AlertsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAuthenticated && !oldWidget.isAuthenticated) {
      _fetchLiveAlerts();
    }
  }

  /// Returns emergency department symbol & color based on incident category
  Widget _buildCategorySymbol(String category, bool isClosed) {
    IconData icon;
    Color color;

    final cat = category.toLowerCase();
    if (cat.contains('police') || cat.contains('assault') || cat.contains('security')) {
      icon = Icons.local_police_rounded;
      color = isClosed ? AppColors.textMuted : AppColors.primaryBlue;
    } else if (cat.contains('fire')) {
      icon = Icons.local_fire_department_rounded;
      color = isClosed ? AppColors.textMuted : AppColors.tacticalOrange;
    } else if (cat.contains('medical') || cat.contains('ambulance')) {
      icon = Icons.medical_services_rounded;
      color = isClosed ? AppColors.textMuted : AppColors.successGreen;
    } else if (cat.contains('sos')) {
      icon = Icons.sos_rounded;
      color = isClosed ? AppColors.textMuted : AppColors.tacticalRed;
    } else if (cat.contains('demo')) {
      // MATCHES CAROUSEL BUG REPORT ICON AND PURPLE PALETTE
      icon = Icons.bug_report_rounded;
      color = isClosed ? AppColors.textMuted : const Color(0xFF8B5CF6);
    } else {
      icon = isClosed ? Icons.history : Icons.warning_amber_rounded;
      color = isClosed ? AppColors.textMuted : AppColors.tacticalOrange;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  /// Handles single-vote enforcement with toggling support
  Future<void> _castIncidentVote(int incidentId, bool isValid) async {
    if (_currentPosition == null || _votingIncidentIds.contains(incidentId)) return;

    if (_votedIncidents[incidentId] == isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You already submitted this vote."),
        backgroundColor: AppColors.surfaceCard,
        duration: Duration(seconds: 1),
      ));
      return;
    }

    setState(() => _votingIncidentIds.add(incidentId));

    try {
      final result = await ApiService.castVote(
        incidentId,
        isValid,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _votedIncidents[incidentId] = isValid;
        });
        _fetchLiveAlerts();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? (result['success'] ? "Vote registered!" : "Vote failed.")),
        backgroundColor: result['success'] ? AppColors.successGreen : AppColors.tacticalRed,
        duration: const Duration(seconds: 2),
      ));
    } finally {
      if (mounted) {
        setState(() => _votingIncidentIds.remove(incidentId));
      }
    }
  }

  Future<void> _fetchLiveAlerts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      Position? pos = await Geolocator.getLastKnownPosition();
      if (pos == null) {
        try {
          pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
          ).timeout(const Duration(seconds: 5));
        } catch (_) {
          pos = Position(
              latitude: 3.8480, longitude: 11.5021,
              timestamp: DateTime.now(), accuracy: 0, altitude: 0,
              heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0
          );
        }
      }
      _currentPosition = pos;

      final token = await ApiService.getToken();

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/incidents?'
            'latitude=${_currentPosition!.latitude}&longitude=${_currentPosition!.longitude}'
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _incidents = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching alerts: $e");
      if (!mounted) return;
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
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
          const Icon(Icons.lock_outline_rounded, size: 80, color: AppColors.borderLight),
          const SizedBox(height: 24),
          const Text(
            "Please log in to view current nearby alerts and history.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: const Text("Log In Now", style: TextStyle(color: AppColors.backgroundBase, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (_incidents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 70, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text("No active or historical alerts in your area.", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _incidents.length,
        itemBuilder: (context, index) {
          final incident = _incidents[index];
          double incidentLat = 3.8480;
          double incidentLng = 11.5021;

          if (incident['location'] != null && incident['location']['coordinates'] != null) {
            incidentLng = (incident['location']['coordinates'][0] as num).toDouble();
            incidentLat = (incident['location']['coordinates'][1] as num).toDouble();
          }

          double distanceInMeters = Geolocator.distanceBetween(
            _currentPosition?.latitude ?? 3.8480, _currentPosition?.longitude ?? 11.5021,
            incidentLat, incidentLng,
          );

          bool isNearby = distanceInMeters <= 1000;
          bool isClosed = (incident['status'] == 'RESOLVED' || incident['status'] == 'FALSE_ALERT');

          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isClosed
                    ? AppColors.borderLight
                    : AppColors.tacticalRed.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySymbol(incident['category'] ?? '', isClosed),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident["category"] ?? "Emergency",
                        style: TextStyle(
                            color: isClosed ? AppColors.textMuted : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        incident["description"] ?? "No description provided",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: isClosed ? AppColors.textMuted : AppColors.primaryBlue, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${(distanceInMeters / 1000).toStringAsFixed(1)} km away",
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (isClosed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      incident['status'] == 'RESOLVED' ? "RESOLVED" : "FALSE ALERT",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Builder(builder: (context) {
                    final int incidentId = incident['id'] ?? 0;
                    final bool? currentVote = _votedIncidents[incidentId];
                    final bool hasConfirmed = currentVote == true;
                    final bool hasContested = currentVote == false;
                    // Check whether THIS specific card is currently voting
                    final bool isThisVoting = _votingIncidentIds.contains(incidentId);

                    return Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasConfirmed ? AppColors.successGreen : Colors.transparent,
                            foregroundColor: hasConfirmed ? Colors.white : (isNearby ? AppColors.successGreen : AppColors.textMuted),
                            side: BorderSide(color: isNearby ? AppColors.successGreen : AppColors.borderLight),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: hasConfirmed ? 4 : 0,
                          ),
                          onPressed: (isNearby && !hasConfirmed && !isThisVoting)
                              ? () => _castIncidentVote(incidentId, true)
                              : null,
                          child: Text(hasConfirmed ? "Confirmed ✓" : "Confirm", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasContested ? AppColors.tacticalRed : Colors.transparent,
                            foregroundColor: hasContested ? Colors.white : (isNearby ? AppColors.tacticalRed : AppColors.textMuted),
                            side: BorderSide(color: isNearby ? AppColors.tacticalRed : AppColors.borderLight),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: hasContested ? 4 : 0,
                          ),
                          onPressed: (isNearby && !hasContested && !isThisVoting)
                              ? () => _castIncidentVote(incidentId, false)
                              : null,
                          child: Text(hasContested ? "Contested ✗" : "Contest", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  }),
              ],
            ),
          );
        }
    );
  }
}