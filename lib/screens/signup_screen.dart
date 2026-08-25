import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '/screens/theme/app_colors.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Form key validation constraints
  final _formKey = GlobalKey<FormState>();

  //Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isOtpSent = false; // toggles between Registration form and OTP verfication

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase, // Swapped to token
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary), // Swapped to token
      ),

      // Body section
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isOtpSent ? _buildOtpView() : _buildRegistrationForm(),
        ),
      ),
    );
  }

  // VIEW  1 : Registration form Widget
  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey, // attaches the validation Key
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          const SizedBox(height: 16),
          const Text("Create Account", style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)), // Swapped to token
          const SizedBox(height: 8),
          const Text("Register your Information to have an account", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)), // Swapped to token
          const SizedBox(height: 32),

          //_buildFormField() for the validation and conformity of the field

          _buildFormField(controller: _nameController, hint: "Full Name", icon: Icons.person_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'This field is required';
                // Regex: strictly allows upper/lowercase letters, spaces, and hyphens. No numbers.
                if (!RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value)) {
                  return 'Name must contain only letters';
                }
                return null;
              }
          ),
          const SizedBox(height: 16),

          _buildFormField(controller: _addressController, hint: "Home Address", icon: Icons.home_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'This field is required';
                if (value.trim().length < 5) return 'Address is too short';
                return null;
              }
          ),
          const SizedBox(height: 16),

          _buildFormField(controller: _phoneController, hint: "Phone Number (+237 6XXX XXX XXX)", icon: Icons.phone_android_rounded,
              isNumeric: true,
              //Data input control for phone number
              validator: (value) {
                if (value == null || value.trim().isEmpty) return "This field is required";

                //Removing spaces from the input
                String rawNumber = value.replaceAll(' ', '');

                //Regex : Optional +237, followed by a 6, followed by exactly 8 digits
                final phoneRegex = RegExp(r'^(?:\+237)?6[0-9]{8}$');

                if (!phoneRegex.hasMatch(rawNumber)) {
                  return "Invalid Cameroon phone number";
                }
                return null;
              }
          ),
          const SizedBox(height: 16),

          _buildFormField(controller: _passwordController, hint: "Password", icon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'This field is required';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              }
          ),
          const SizedBox(height: 16),
          _buildFormField(controller: _confirmPasswordController, hint: "Confirm Password", icon: Icons.lock_rounded, isPassword: true,
            //validation logic to ensure passwords match
            validator: (value) {
              if (value == null || value.isEmpty) return "This field is required";
              if (value != _passwordController.text) return "Password do not Match";
              return null;
            },
          ),
          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue, // Swapped to token
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: (){
                //Validation Check to ensure all required constraints are met
                if (_formKey.currentState!.validate()){
                  setState(() {
                    _isOtpSent = true; // switch to OTP screen
                  });
                  debugPrint("Registration Valide. sending the OTP to ${_phoneController.text}"); // Added .text for accurate logging
                }
              },
              child: const Text("Register and Send Code", style: TextStyle(color: AppColors.backgroundBase, fontSize: 16, fontWeight: FontWeight.bold)), // Swapped to token
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // VIEW 2 : OTP Form Widget (Restructured with 6 real digits)
  Widget _buildOtpView() {
    // 1. Define the default appearance of the OTP boxes (Unfocused)
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 22,
        color: AppColors.textPrimary, // High contrast text
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard, // Uses our tactical dark theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
    );

    // 2. Define the appearance when a box is actively focused
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primaryBlue, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    // 3. Define the appearance when a box has a number inside it (submitted)
    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppColors.backgroundBase, // Subtle color shift when filled
      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        const Text("Verify Identity",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter the 6-digit secure code sent to ${_phoneController.text}",
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // THE NEW 6-BOX OTP INPUT WIDGET
        Pinput(
          length: 6, // Standard 6-digit Twilio/Firebase OTP
          controller: _otpController,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          showCursor: true,
          // Automatically logs when the user finishes typing the 6th digit
          onCompleted: (pin) {
            debugPrint("OTP Fully Typed: $pin");
          },
        ),
        const SizedBox(height: 48),

        // VERIFY BUTTON
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              // MVP Constraint: Ensure the user typed exactly 6 digits before proceeding
              if (_otpController.text.length == 6) {
                debugPrint("OTP Verified! Returning to homepage...");

                // Pop and return the data map to unlock the Citizen Mode on the Map
                Navigator.pop(context, {
                  "name": _nameController.text,
                  "phone": _phoneController.text,
                });
              } else {
                // Safety net: Alert if they try to submit less than 6 digits
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter the complete 6-digit code."),
                    backgroundColor: AppColors.tacticalRed,
                  ),
                );
              }
            },
            child: const Text("Verify OTP",
              style: TextStyle(color: AppColors.backgroundBase, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // decleration of the _buildFormField Widget
  Widget _buildFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isNumeric = false,
    bool alignCenter = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      textAlign: alignCenter ? TextAlign.center : TextAlign.start,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16), // Swapped to token
      //Standard requirement Logic
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field is required";
        }
        return null; // validation is ok
      },

      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceCard, // Swapped to token
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted), // Swapped to token
        prefixIcon: Icon(icon, color: AppColors.textMuted), // Swapped to token
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColors.textMuted), // Swapped to token
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),

        //Design for default, active, and error states
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)), // Swapped to token
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.tacticalRed, width: 1.5)), // Swapped to token
      ),
    );
  }
}