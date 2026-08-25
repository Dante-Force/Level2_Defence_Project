import 'package:flutter/material.dart';
import '/screens/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // toggle to show or hide password

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
      
      // body Section 
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              
              children: [
                const SizedBox(height: 32),
                const Text("Log In Form", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),),
                
                const SizedBox(height: 8),
                const Text(
                  "Enter your registered phone number and password to access your account.",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                //phone Number
                _buildInputField(
                  controller : _phoneController,
                  hintText : "+237 6XX XXX XXX",
                  icon :Icons.phone_android_rounded,
                  keyboardType : TextInputType.phone,
                ),
                const SizedBox(height: 24),

                //password Input
                _buildInputField(
                  controller : _passwordController,
                  hintText : "Password",
                  icon :Icons.lock_outline_rounded,
                  isPassword : true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () => debugPrint("Forgot Password Tapped"),
                      child: const Text("Forgot Password ?", style: TextStyle(color: Color(0xFF38BDF8))),
                  ),
                ),

                const SizedBox(height: 20),

                //Log in action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: (){
                      // MVP Validation check
                      if (_phoneController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                        debugPrint("Authentication...");
                        //Pop the screen and return "true" to signal a successful login
                        Navigator.pop(context, true);
                      } else {
                        debugPrint("Validation Failed: Empty fields");
                      }
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  // Declaration of widget variable for the inputs
  Widget _buildInputField({
   required TextEditingController controller,
   required String hintText,
   required IconData icon,
   bool isPassword = false,
   TextInputType keyboardType = TextInputType.text,
}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
          suffixIcon: isPassword
            ? IconButton(
              onPressed: (){
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible; // flips the boolean to reveal/hide text
                });
              },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: const Color(0xFF94A3B8),
              ),
              )
            : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
