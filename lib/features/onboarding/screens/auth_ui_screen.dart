import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../utils/colors/app_colors.dart';
import '../widgets/auth_input_field.dart';

class AuthUiScreen extends StatefulWidget {
  const AuthUiScreen({super.key});

  @override
  State<AuthUiScreen> createState() => _AuthUiScreenState();
}

class _AuthUiScreenState extends State<AuthUiScreen> {
  late AuthController _authController; 

  final _nameController = TextEditingController(); 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _authController = Get.put(AuthController());//initializing auth controller 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
//check if email and password are valid or not using regular expression
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }
// while tap handle login/submit cases , add forget password in future and verification via otp 
  void _handleSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
//empty field cases 
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
//when email format is not regx
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format")),
      );
      return;
    }
//when all validation passed
    if (_isLogin) {
      _authController.login(
        email: email,
        password: password,
      );
    } else {
      //when name is empty, bcz its not shown in login only shown in signin: sigin begin
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your name")),
        );
        return;
      }

      if (!_isValidPassword(password)) {
        //when password format is not correct
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password must have 8+ chars, uppercase, lowercase, number"),
          ),
        );
        return;
      }
//when all validation pass , call sign up
      _authController.signUp(
        name: name,
        email: email,
        password: password,
      );
    }
  }

  void _toggleAuthMode() {
    setState(() { //when user toggled from togin to signup or vice versa
      _isLogin = !_isLogin;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _showPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.eco_outlined, size: 60, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text("Culina.", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? "Welcome Back" : "Create Account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                // Profile image picker (only for signup)
                if (!_isLogin)
                  Obx(() => GestureDetector(
                    onTap: _authController.pickProfileImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _authController.profileImage.value != null
                          ? FileImage(_authController.profileImage.value!)
                          : null,
                      child: _authController.profileImage.value == null
                          ? const Icon(Icons.camera_alt)
                          : null,
                    ),
                  )),
                if (!_isLogin) const SizedBox(height: 32),
                // Name field (only for signup)
                if (!_isLogin)
                  AuthInputField(
                    hint: "Full Name",
                    controller: _nameController,
                  ),
                if (!_isLogin) const SizedBox(height: 12),
                // Email field
                AuthInputField(
                  hint: "Email",
                  controller: _emailController,
                ),
                const SizedBox(height: 12),
                // Password field with visibility toggle
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                        debugPrint('👁️ [UI] Password visibility toggled: $_showPassword');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Password requirements (only for signup)
                if (!_isLogin)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password must have: 8+ chars, uppercase, lowercase, number',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Error message display
                Obx(() => _authController.errorMessage.value.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _authController.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : const SizedBox()),
                const SizedBox(height: 16),
                // Submit button
                Obx(() => _authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isLogin ? "Login" : "Create Account",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                const SizedBox(height: 16),
                // Toggle auth mode button
                TextButton(
                  onPressed: _toggleAuthMode,
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Login",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
