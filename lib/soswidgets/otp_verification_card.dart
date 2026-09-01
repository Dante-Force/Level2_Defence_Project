import 'package:flutter/material.dart';
import '../screens/theme/app_colors.dart';
import '../services/api_service.dart';

class OtpVerificationCard extends StatefulWidget {
  final String phoneNumber;
  final String password;
  final Function(Map<String, dynamic> result) onSuccess;
  final VoidCallback onCancel;

  const OtpVerificationCard({
    super.key,
    required this.phoneNumber,
    required this.password,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<OtpVerificationCard> createState() => _OtpVerificationCardState();
}

class _OtpVerificationCardState extends State<OtpVerificationCard> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showSnackBar("Please enter the full 6-digit OTP code.", AppColors.tacticalOrange);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.verifyOtp(widget.phoneNumber, otp);

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      _showSnackBar("Authentication successful!", AppColors.successGreen);
      widget.onSuccess(result);
    } else {
      _showSnackBar("Invalid 6-digit OTP code.", AppColors.tacticalRed);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read_rounded, size: 40, color: AppColors.primaryBlue),
          const SizedBox(height: 12),
          const Text(
            "6-Digit Verification PIN",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Code sent for account: ${widget.phoneNumber}",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 6-DIGIT OTP PIN INPUT
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundBase,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                hintText: "123456",
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 18, letterSpacing: 4),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // VERIFY & LOGIN BUTTON WITH SPINNER
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: AppColors.textPrimary, strokeWidth: 2.5),
              )
                  : const Text(
                "VERIFY & LOGIN",
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ),
          ),

          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text("← Change Credentials", style: TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}