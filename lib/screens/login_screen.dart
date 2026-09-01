import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import '../services/api_service.dart';
import '../soswidgets/otp_verification_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _otpSent = false;
  bool _isLoading = false;

  // REQUEST OTP CODE AFTER VALIDATING PHONE & PASSWORD
  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter both your phone number and password.", AppColors.tacticalOrange);
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.requestOtp(phone);

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _otpSent = true);
      _showSnackBar("OTP Code dispatched! Check server log for 6-digit PIN.", AppColors.successGreen);
    } else {
      _showSnackBar("Failed to send OTP. Ensure backend server is online.", AppColors.tacticalRed);
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
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Citizen Login",
                style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your phone number & password to request a 6-digit verification PIN.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // IF OTP IS SENT -> EMBED MODULAR OTP CARD
              if (_otpSent)
                OtpVerificationCard(
                  phoneNumber: _phoneController.text.trim(),
                  password: _passwordController.text.trim(),
                  onSuccess: (result) {
                    Navigator.pop(context, {'phone': _phoneController.text.trim()});
                  },
                  onCancel: () {
                    setState(() => _otpSent = false);
                  },
                )
              else ...[
                // PHONE INPUT
                _buildInputField(
                  controller: _phoneController,
                  hintText: "+237 6XX XXX XXX",
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // PASSWORD INPUT
                _buildInputField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 24),

                // REQUEST OTP BUTTON WITH SPINNER
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _requestOtp,
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Text(
                      "REQUEST OTP PIN",
                      style: TextStyle(color: AppColors.backgroundBase, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          suffixIcon: isPassword
              ? IconButton(
            onPressed: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: AppColors.textMuted,
            ),
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}