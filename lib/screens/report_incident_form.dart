import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '/screens/theme/app_colors.dart';
import '/soswidgets/visual_evidence_picker.dart'; // YOUR NEW WIDGET

//for live reporting processing
import 'package:geolocator/geolocator.dart';
import '/services/api_service.dart';

class ReportIncidentForm extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const ReportIncidentForm({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<ReportIncidentForm> createState() => _ReportIncidentFormState();
}

class _ReportIncidentFormState extends State<ReportIncidentForm> {
  final TextEditingController _descriptionController = TextEditingController();

  // Clean State Tracking
  File? _finalPhoto;
  File? _finalVideo;
  bool _hasAudio = false;
  bool _isRecordingAudio = false;
  int _audioSeconds = 0;
  Timer? _audioTimer;
  bool _isSubmitting = false;

  bool get isDemo => widget.categoryName.toLowerCase().contains('demo');

  @override
  void dispose() {
    _descriptionController.dispose();
    _audioTimer?.cancel();
    super.dispose();
  }

  // Audio Logic
  void _toggleAudioRecording() {
    if (_isRecordingAudio) {
      _stopAudioRecording();
    } else {
      setState(() {
        _isRecordingAudio = true;
        _hasAudio = false;
        _audioSeconds = 0;
      });

      _audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _audioSeconds++);
        if (_audioSeconds >= 10) _stopAudioRecording();
      });
    }
  }

  void _stopAudioRecording() {
    _audioTimer?.cancel();
    setState(() {
      _isRecordingAudio = false;
      _hasAudio = true;
    });
  }

  // Submission Logic connected to live ApiService & GPS
  Future<void> _submitReport() async {
    if (!_hasAudio) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("VOICE AUDIO IS MANDATORY. Please record a brief audio description."),
        backgroundColor: AppColors.tacticalRed,
      ));
      return;
    }

    if (_finalPhoto == null && _finalVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("VISUAL EVIDENCE IS MANDATORY. Please attach a photo, a video, or both."),
        backgroundColor: AppColors.tacticalRed,
      ));
      return;
    }

    setState(() => _isSubmitting = true);

    // Fetch live GPS location or default to Yaoundé coordinates
    double lat = 3.8480;
    double lng = 11.5021;

    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (e) {
      debugPrint("Using default Yaoundé coordinates: $e");
    }

    final success = await ApiService.submitIncident(
      category: widget.categoryName,
      description: _descriptionController.text.trim().isEmpty
          ? "${widget.categoryName} emergency reported with mandatory evidence."
          : _descriptionController.text.trim(),
      latitude: lat,
      longitude: lng,
      mediaFile: _finalPhoto ?? _finalVideo,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Alert broadcasted to server! AI Triage active."),
        backgroundColor: AppColors.successGreen,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transmission failed. Ensure backend server is online."),
        backgroundColor: AppColors.tacticalRed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Row(
          children: [
            Icon(widget.categoryIcon, color: widget.categoryColor),
            const SizedBox(width: 10),
            Text("Report ${widget.categoryName}", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DYNAMIC INSTRUCTION BANNER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.categoryColor.withValues(alpha: 0.1),
                border: Border.all(color: widget.categoryColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(isDemo ? Icons.science_rounded : Icons.warning_amber_rounded, color: widget.categoryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDemo
                          ? "DEMO MODE ACTIVE: Hardware restrictions lifted. Gallery access enabled for defense simulation."
                          : "False reports are tracked by GPS and punishable by law.",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. AUDIO SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child:  Text(
                        "Voice Audio (MANDATORY)*",
                        style: TextStyle(color: AppColors.tacticalRed, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                ),
                const SizedBox(width: 8),
                const Text("Max 10s", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: Text(
                "Please state your exact location and describe the incident clearly.",
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            GestureDetector(
              onTap: _toggleAudioRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 70,
                decoration: BoxDecoration(
                  color: _isRecordingAudio ? AppColors.tacticalRed.withValues(alpha: 0.2) : (_hasAudio ? AppColors.successGreen.withValues(alpha: 0.2) : AppColors.surfaceCard),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isRecordingAudio ? AppColors.tacticalRed : (_hasAudio ? AppColors.successGreen : AppColors.borderLight), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRecordingAudio ? Icons.stop_circle_rounded : (_hasAudio ? Icons.check_circle_rounded : Icons.mic_rounded),
                      color: _isRecordingAudio ? AppColors.tacticalRed : (_hasAudio ? AppColors.successGreen : AppColors.primaryBlue), size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isRecordingAudio ? "Recording... 00:0${_audioSeconds}s" : (_hasAudio ? "Audio Captured (Tap to re-record)" : "Tap to Record Voice"),
                      style: TextStyle(color: _isRecordingAudio ? AppColors.tacticalRed : (_hasAudio ? AppColors.successGreen : AppColors.textPrimary), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. THE EXTRACTED VISUAL MEDIA WIDGET
            VisualEvidencePicker(
              isDemo: isDemo, // Passes the Demo flag perfectly
              onMediaCaptured: (photo, video) {
                // Instantly updates the main form state when media is selected
                setState(() {
                  _finalPhoto = photo;
                  _finalVideo = video;
                });
              },
            ),
            const SizedBox(height: 24),

            // 4. DESCRIPTION INPUT
            const Text("Additional Text (Optional)", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Add specific details...",
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceCard,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderLight)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2)),
              ),
            ),
            const SizedBox(height: 40),

            // 5. SUBMIT BUTTON
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("BROADCAST ALERT", style: TextStyle(color: AppColors.backgroundBase, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}