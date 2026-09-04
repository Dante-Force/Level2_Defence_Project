import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/theme/app_colors.dart';
import '../screens/alerts_screen.dart';

import '../services/api_service.dart'; // IMPORTANT: Added ApiService import

class LiveMapView extends StatefulWidget {
  final bool isAuthenticated;
  const LiveMapView({super.key, required this.isAuthenticated});

  @override
  State<LiveMapView> createState() => _LiveMapViewState();
}

class _LiveMapViewState extends State<LiveMapView> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(3.8480, 11.5021);
  bool _isLoadingLocation = true;

  StreamSubscription<Position>? _positionStream;
  Timer? _pollingTimer; // NEW: Timer for live polling

  LatLng? _closestIncident;

  // NEW: Changed from fake LatLng list to a dynamic list holding real database incidents
  List<Map<String, dynamic>> _activeIncidents = [];

  @override
  void initState() {
    super.initState();
    _startLiveTracking();

    // NEW: Automatically fetch real incidents from Laravel every 15 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchLiveIncidents());
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  // --- NEW: FETCH INCIDENTS FROM BACKEND ---
  Future<void> _fetchLiveIncidents() async {
    if (!widget.isAuthenticated) return;

    final incidents = await ApiService.getIncidents(_currentPosition.latitude, _currentPosition.longitude);

    if (mounted) {
      setState(() {
        _activeIncidents = List<Map<String, dynamic>>.from(incidents);
      });
    }
  }

  // --- NEW: HELPER TO EXTRACT POSTGIS GeoJSON COORDINATES ---
  LatLng? _parseLocation(dynamic loc) {
    if (loc != null && loc['coordinates'] != null) {
      // GeoJSON standard: [longitude, latitude]
      return LatLng(loc['coordinates'][1].toDouble(), loc['coordinates'][0].toDouble());
    }
    return null;
  }

  Future<void> _startLiveTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    Position initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _updatePositionAndRoute(initialPosition);
    _mapController.move(_currentPosition, 13.0);

    // Fetch incidents immediately upon getting first GPS lock
    _fetchLiveIncidents();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position livePosition) {
      _updatePositionAndRoute(livePosition);
    });
  }

  void _updatePositionAndRoute(Position pos) {
    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _isLoadingLocation = false;

      if (widget.isAuthenticated && _activeIncidents.isNotEmpty) {
        double minDistance = double.infinity;
        LatLng? closest;

        for (var incident in _activeIncidents) {
          LatLng? loc = _parseLocation(incident['location']);
          if (loc == null) continue;

          double dist = Geolocator.distanceBetween(
            _currentPosition.latitude, _currentPosition.longitude,
            loc.latitude, loc.longitude,
          );

          if (dist < minDistance) {
            minDistance = dist;
            closest = loc;
          }
        }
        _closestIncident = closest;
      }
    });
  }

  // NEW: Updated to accept full database dictionary instead of just LatLng
  void _showIncidentDetails(Map<String, dynamic> incident) {
    LatLng? incidentLocation = _parseLocation(incident['location']);
    if (incidentLocation == null) return;

    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition.latitude, _currentPosition.longitude,
      incidentLocation.latitude, incidentLocation.longitude,
    );

    String distanceString = (distanceInMeters / 1000).toStringAsFixed(2);
    String categoryName = incident['category'] ?? "Emergency";
    int trustScore = incident['ai_trust_score'] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppColors.tacticalOrange, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    categoryName.toUpperCase(),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Distance: $distanceString km away",
                style: const TextStyle(color: AppColors.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "AI Trust Score: $trustScore/100",
                style: const TextStyle(color: AppColors.successGreen, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AlertsScreen(isAuthenticated: widget.isAuthenticated)),
                        );
                      },
                      child: const Text("More Info", style: TextStyle(color: AppColors.backgroundBase, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side:
                        BorderSide(color: AppColors.borderLight),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close", style: TextStyle(color: AppColors.textPrimary)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition,
            initialZoom: 13.0,
            interactionOptions: InteractionOptions(
              flags: widget.isAuthenticated ? InteractiveFlag.all : InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.sos_report',
            ),

            if (widget.isAuthenticated) ...[
              CircleLayer(
                circles: _activeIncidents.where((inc) => inc['status'] == 'VALIDATED').map((incident) {
                  LatLng? loc = _parseLocation(incident['location']);
                  if (loc == null) return null;
                  return CircleMarker(
                    point: loc,
                    color: AppColors.tacticalRed.withValues(alpha: 0.15),
                    borderColor: AppColors.tacticalRed.withValues(alpha: 0.8),
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                    radius: 1000,
                  );
                }).whereType<CircleMarker>().toList(),
              ),

              MarkerLayer(
                markers: _activeIncidents.where((inc) => inc['status'] == 'VALIDATED').map((incident) {
                  LatLng? loc = _parseLocation(incident['location']);
                  if (loc == null) return null;
                  return Marker(
                    point: loc,
                    width: 50, height: 50,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => _showIncidentDetails(incident),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.tacticalRed,
                        size: 45,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                    ),
                  );
                }).whereType<Marker>().toList(),
              ),
            ],

            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition,
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // 2. NEW: The Floating "Area Secure" Badge
        if (widget.isAuthenticated && _activeIncidents.isEmpty && !_isLoadingLocation)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundBase.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.5)),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, color: AppColors.successGreen, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Area Secure - No Active Incidents",
                      style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}