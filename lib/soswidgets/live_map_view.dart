import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/theme/app_colors.dart';
import '../screens/alerts_screen.dart';

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

  // NEW: Stream to track the user actively walking
  StreamSubscription<Position>? _positionStream;

  // NEW: Holds the dynamically calculated closest incident
  LatLng? _closestIncident;

  final List<LatLng> _activeIncidents = [
    const LatLng(3.8600, 11.5150),
    const LatLng(3.8350, 11.4900),
  ];

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Stop tracking when map is closed to save battery
    super.dispose();
  }

  /// UPGRADED: Actively listens to GPS changes instead of fetching just once
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

    // 1. Get initial position immediately
    Position initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _updatePositionAndRoute(initialPosition);
    _mapController.move(_currentPosition, 13.0);

    // 2. Start Live Stream (Updates every time user moves 5 meters)
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position livePosition) {
      _updatePositionAndRoute(livePosition);
    });
  }

  /// CORE LOGIC: Finds the absolute closest incident to draw the permanent line
  void _updatePositionAndRoute(Position pos) {
    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _isLoadingLocation = false;

      // Only calculate routing if authenticated and incidents exist
      if (widget.isAuthenticated && _activeIncidents.isNotEmpty) {
        double minDistance = double.infinity;
        LatLng? closest;

        for (var incident in _activeIncidents) {
          double dist = Geolocator.distanceBetween(
            _currentPosition.latitude, _currentPosition.longitude,
            incident.latitude, incident.longitude,
          );

          if (dist < minDistance) {
            minDistance = dist;
            closest = incident;
          }
        }

        // Lock the permanent blue line to the closest incident
        _closestIncident = closest;
      }
    });
  }

  void _showIncidentDetails(LatLng incidentLocation) {
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition.latitude,
      _currentPosition.longitude,
      incidentLocation.latitude,
      incidentLocation.longitude,
    );

    String distanceString = (distanceInMeters / 1000).toStringAsFixed(2);

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
              const Row(
                children: [
                  Icon(Icons.local_fire_department, color: AppColors.tacticalOrange, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "Active Emergency",
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Distance: $distanceString km away",
                style: const TextStyle(color: AppColors.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold),
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
                          MaterialPageRoute(builder: (context) =>  AlertsScreen(isAuthenticated: widget.isAuthenticated)),
                        );
                      },
                      child: const Text("More Info", style: TextStyle(color: AppColors.backgroundBase, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side:   BorderSide(color: AppColors.borderLight),
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
    // NOTICE: We removed the .whenComplete cleanup logic! The line is now permanent.
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
            circles: _activeIncidents.map((incident) => CircleMarker(
              point: incident,
              color: AppColors.tacticalRed.withValues(alpha: 0.15),
              borderColor: AppColors.tacticalRed.withValues(alpha: 0.8),
              borderStrokeWidth: 2,
              useRadiusInMeter: true,
              radius: 1000,
            )).toList(),
          ),


          MarkerLayer(
            markers: _activeIncidents.map((incident) => Marker(
              point: incident,
              width: 50,
              height: 50,
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
            )).toList(),
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
    );
  }
}