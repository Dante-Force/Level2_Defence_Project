import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../screens/theme/app_colors.dart';
import '../services/api_service.dart';

class SOSTriggerOverlay extends StatefulWidget {
  const SOSTriggerOverlay({super.key});

  @override
  State<SOSTriggerOverlay> createState() => _SOSTriggerOverlayState();
}

class _SOSTriggerOverlayState extends State<SOSTriggerOverlay> {
  // Phase control
  int _countdown = 3;
  bool _isRecording = false;
  bool _isSubmitting = false;
  int _recordingSeconds = 5;
  Timer? _sequenceTimer;

  // Real audio recorder instance
  final AudioRecorder _recorder = AudioRecorder();
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _startCountdownPhase();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // PHASE 1: 3-Second Safety Delay (User can still ABORT)
  // -------------------------------------------------------
  void _startCountdownPhase() {
    _sequenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        // Countdown finished → transition to Phase 2
        _sequenceTimer?.cancel();
        setState(() => _isRecording = true);
        _startRecordingPhase();
      }
    });
  }

  // -------------------------------------------------------
  // PHASE 2: 5-Second REAL Ambient Audio Capture
  // Uses the `record` package to capture from the microphone
  // -------------------------------------------------------
  Future<void> _startRecordingPhase() async {
    // 1. Start real microphone recording
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _audioFilePath =
        '${dir.path}/sos_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _audioFilePath!,
        );
        debugPrint("SOS: Microphone recording started → $_audioFilePath");
      } else {
        debugPrint("SOS: Microphone permission denied.");
      }
    } catch (e) {
      debugPrint("SOS: Audio recording start failed: $e");
    }

    // 2. Visual countdown for recording phase
    _sequenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_recordingSeconds > 1) {
        setState(() => _recordingSeconds--);
      } else {
        // Recording complete → dispatch SOS
        _sequenceTimer?.cancel();
        _dispatchSOS();
      }
    });
  }

  // -------------------------------------------------------
  // PHASE 3: Stop recording, capture GPS, submit to backend
  // Routes to Police dashboard via category: 'SOS'
  // -------------------------------------------------------
  Future<void> _dispatchSOS() async {
    setState(() => _isSubmitting = true);

    // 1. Stop audio recording and get the saved file
    File? audioFile;
    try {
      final path = await _recorder.stop();
      if (path != null && await File(path).exists()) {
        audioFile = File(path);
        debugPrint("SOS: Audio captured successfully → $path");
      }
    } catch (e) {
      debugPrint("SOS: Audio stop error: $e");
    }

    // 2. Get live GPS coordinates (fallback to Yaoundé center)
    double lat = 3.8480;
    double lng = 11.5021;
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));
      lat = pos.latitude;
      lng = pos.longitude;
      debugPrint("SOS: GPS locked → ($lat, $lng)");
    } catch (e) {
      debugPrint("SOS: GPS fallback to Yaoundé center: $e");
    }

    // 3. Submit SOS incident to backend API
    //    Category 'SOS' ensures it routes to Police + Admin dashboards
    final List<File> mediaFiles = [];
    if (audioFile != null) mediaFiles.add(audioFile);

    final success = await ApiService.submitIncident(
      category: 'SOS',
      description:
      'CRITICAL SOS TRIGGER — Ambient audio captured at coordinates ($lat, $lng). Dispatching to Police.',
      latitude: lat,
      longitude: lng,
      mediaFiles: mediaFiles.isNotEmpty ? mediaFiles : null,
    );

    debugPrint("SOS: API submission ${success ? 'SUCCEEDED' : 'FAILED'}");

    if (!mounted) return;
    // Pop overlay and return success status to visitor_home_screen
    Navigator.pop(context, success);
  }

  // -------------------------------------------------------
  // ABORT: User cancels during the 3-second countdown
  // -------------------------------------------------------
  void _cancelSOS() {
    _sequenceTimer?.cancel();
    _recorder.stop(); // Stop recorder if it somehow started
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Blood red background for high emergency visibility
      backgroundColor: AppColors.tacticalRed,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSubmitting
                    ? Icons.cell_tower_rounded
                    : Icons.warning_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),

              Text(
                _isSubmitting
                    ? "TRANSMITTING TO POLICE..."
                    : _isRecording
                    ? "RECORDING AMBIENT AUDIO"
                    : "INITIATING SOS PROTOCOL",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 48),

              // DYNAMIC CIRCULAR TIMER
              if (!_isSubmitting)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isRecording ? "$_recordingSeconds" : "$_countdown",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 64),

              // CANCEL BUTTON (Only available during the 3-second countdown)
              if (!_isRecording && !_isSubmitting)
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.tacticalRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _cancelSOS,
                    child: const Text(
                      "ABORT",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                )
              else if (_isSubmitting)
              // Submitting visual feedback
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Sending to emergency services...",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                )
              else
              // High-tension visual feedback during recording
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Do not close the app...",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}