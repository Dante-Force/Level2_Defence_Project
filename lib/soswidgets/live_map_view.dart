// lib/widgets/live_map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/screens/theme/app_colors.dart';

class LiveMapView extends StatelessWidget {
  const LiveMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(3.8480, 11.5021), // Yaoundé coordinates
        initialZoom: 14.5,
      ),
      children: [
        // 1. OPENSTREETMAP TILES
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.aics.sos',
        ),

        // 2. INCIDENT HEATPINS & USER LOCATION
        MarkerLayer(
          markers: [
            // USER LOCATION PIN (Civic Blue)
            const Marker(
              point: LatLng(3.8480, 11.5021),
              width: 50,
              height: 50,
              child: Icon(
                Icons.my_location_rounded,
                color: Color(0xFF2563EB),
                size: 32,
              ),
            ),

            // MEDICAL EMERGENCY
            Marker(
              point: const LatLng(3.8520, 11.5060),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => debugPrint("Tapped Medical Incident Pin"),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF10B981),
                  size: 40,
                ),
              ),
            ),

            // FIRE OUTBREAK
            Marker(
              point: const LatLng(3.8440, 11.4980),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => debugPrint("Tapped Fire Incident Pin"),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFF97316),
                  size: 40,
                ),
              ),
            ),

            // DANGER / SOS TRIGGER
            Marker(
              point: const LatLng(3.8495, 11.5000),
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => debugPrint("Tapped Danger Incident Pin"),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFFF3B30),
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}