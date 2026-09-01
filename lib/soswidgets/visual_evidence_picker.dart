import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/theme/app_colors.dart';

class VisualEvidencePicker extends StatefulWidget {
  final bool isDemo; // Receives the demo flag from the parent
  final Function(File? photo, File? video) onMediaCaptured;

  const VisualEvidencePicker({
    super.key,
    required this.isDemo,
    required this.onMediaCaptured,
  });

  @override
  State<VisualEvidencePicker> createState() => _VisualEvidencePickerState();
}

class _VisualEvidencePickerState extends State<VisualEvidencePicker> {
  File? _capturedPhoto;
  File? _capturedVideo;

  Future<void> _capturePhoto() async {
    final ImagePicker picker = ImagePicker();
    // THE DEMO BYPASS: Uses Gallery if Demo, else strictly Camera
    final XFile? photo = await picker.pickImage(
      source: widget.isDemo ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 70,
    );

    if (photo != null) {
      setState(() => _capturedPhoto = File(photo.path));
      widget.onMediaCaptured(_capturedPhoto, _capturedVideo); // Send back to parent
    }
  }

  Future<void> _captureVideo() async {
    final ImagePicker picker = ImagePicker();
    // THE DEMO BYPASS: Uses Gallery if Demo, else strictly Camera
    final XFile? video = await picker.pickVideo(
      source: widget.isDemo ? ImageSource.gallery : ImageSource.camera,
      maxDuration: const Duration(seconds: 15),
    );

    if (video != null) {
      setState(() => _capturedVideo = File(video.path));
      widget.onMediaCaptured(_capturedPhoto, _capturedVideo); // Send back to parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Visual Evidence (MANDATORY)*",
                style: TextStyle(color: AppColors.tacticalRed, fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text("Select 1 or both", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),

        // ACTION BUTTONS
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceCard,
                  side: BorderSide(color: _capturedPhoto != null ? AppColors.successGreen : AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(
                  _capturedPhoto != null ? Icons.check_circle : Icons.camera_alt_rounded,
                  color: _capturedPhoto != null ? AppColors.successGreen : AppColors.primaryBlue,
                ),
                label: const Text("Photo", style: TextStyle(color: AppColors.textPrimary)),
                onPressed: _capturePhoto,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceCard,
                  side: BorderSide(color: _capturedVideo != null ? AppColors.successGreen : AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(
                  _capturedVideo != null ? Icons.check_circle : Icons.videocam_rounded,
                  color: _capturedVideo != null ? AppColors.successGreen : AppColors.primaryBlue,
                ),
                label: const Text("Video (15s)", style: TextStyle(color: AppColors.textPrimary)),
                onPressed: _captureVideo,
              ),
            ),
          ],
        ),

        // DYNAMIC PREVIEW ROW
        if (_capturedPhoto != null || _capturedVideo != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (_capturedPhoto != null)
                Expanded(
                  child: Container(
                    height: 120,
                    margin: EdgeInsets.only(right: _capturedVideo != null ? 8.0 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                      image: DecorationImage(image: FileImage(_capturedPhoto!), fit: BoxFit.cover),
                    ),
                  ),
                ),
              if (_capturedVideo != null)
                Expanded(
                  child: Container(
                    height: 120,
                    margin: EdgeInsets.only(left: _capturedPhoto != null ? 8.0 : 0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                    ),
                    child: Center(
                      child: Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryBlue.withValues(alpha: 0.8), size: 48),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}