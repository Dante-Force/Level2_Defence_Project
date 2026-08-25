import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/theme/app_colors.dart';

class SOSTriggerOverlay extends StatefulWidget {
  const SOSTriggerOverlay({super.key});

  @override
  State<SOSTriggerOverlay> createState() => _SOSTriggerOverlayState();
}

class _SOSTriggerOverlayState extends State<SOSTriggerOverlay> {
  int _countdown = 3;
  bool _isRecording = false;
  int _recordingSeconds = 5;
  Timer? _sequenceTimer;

  @override
  void initState() {
    super.initState();
    _startCountdownPhase();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    super.dispose();
  }

  // PHASE 1: 3-Second Safety Delay
  void _startCountdownPhase() {
    _sequenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        // Countdown finished, transition to Phase 2
        _sequenceTimer?.cancel();
        setState(() => _isRecording = true);
        _startRecordingPhase();
      }
    });
  }

  // PHASE 2: 5-Second Ambient Audio Capture
  void _startRecordingPhase() {
    _sequenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_recordingSeconds > 1) {
        setState(() => _recordingSeconds--);
      } else {
        // Sequence complete! Dispatch the alert.
        _sequenceTimer?.cancel();
        _dispatchSOS();
      }
    });
  }

  void _dispatchSOS() {
    // Pop the overlay and return 'true' to signal a successful broadcast
    Navigator.pop(context, true);
  }

  void _cancelSOS() {
    _sequenceTimer?.cancel();
    // Pop the overlay and return 'false' to signal cancellation
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
              const Icon(
                Icons.warning_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),

              Text(
                _isRecording ? "RECORDING AMBIENT AUDIO" : "INITIATING SOS PROTOCOL",
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
              if (!_isRecording)
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
              else
              // High-tension visual feedback during recording
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Do not close the app...",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}