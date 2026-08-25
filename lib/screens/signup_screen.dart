import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Register your Information to have an account", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
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
                backgroundColor: const Color(0xFF38BDF8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
                onPressed: (){
                 //Validation Check to ensure all required constraints are met
                  if (_formKey.currentState!.validate()){
                    setState(() {
                      _isOtpSent = true; // switch to OTP screen
                    });
                    debugPrint("Registration Valide. sending the OTP to ${_phoneController}");
                  }
                },
                child: const Text("Register and Send Code", style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
}

  // VIEW 2 : OTP Form Widget
  Widget _buildOtpView(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        const SizedBox(height: 48),
        const Text("Verify Identity", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Enter the 6-digit secure code sent to ${_phoneController}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5)),
        const SizedBox(height: 48),

        _buildFormField(controller: _otpController, hint: "......", icon: Icons.message_rounded, isNumeric: true, alignCenter: true),
        const SizedBox(height: 48),
        
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
            ),
              onPressed: () {
               if (_otpController.text.isNotEmpty) {
                 debugPrint("OTP Verified ! Returning to homepage..");

                 //Pop and return "true" to log the user in with typed data into the map
                 Navigator.pop(context, {
                   "name": _nameController.text,
                   "phone": _phoneController.text,
                 });
                }
               },
            child: const Text("Verify OTP", style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
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
      style: TextStyle(color: Colors.white, fontSize: 16),
      //Standard requirement Logic
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field is required";
        }
        return null; // validation is ok
      },

      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFF94A3B8)),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        )
        : null,
        contentPadding: EdgeInsets.symmetric(vertical: 18),

        //Design for default, active, and error states
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5)),
        ),
      );
    }
  }
