import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/assets_path.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_background.dart';
import '../dashboard/dashboard_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (authProvider.user != null && mounted) {
        NavigationHelper.navigateToAndRemoveUntil(
          context,
          const DashboardScreen(),
        );
      }
    }
  }

  // Function to navigate to signup screen
  void _goToSignup() {
    NavigationHelper.navigateTo(context, const SignupScreen());
  }

  // Function to handle reset password
  void _resetPassword() {
    // Add password reset functionality here
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Main container with gradient background
      body: Container(
        // Green gradient background from dark to light
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000900),
              Color(0xFF026A02),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title text
                    const SizedBox(height: 50),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 170),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // White container with form
                        Container(
                          margin: const EdgeInsets.only(
                            top: 100,
                          ), // Add margin to lower the form
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 100,
                              ), // Increased space for larger mango image
                              // Welcome text
                              const Text(
                                "Welcome back",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Sign in to your account",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Email field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: FormValidators.validateEmail,
                                  decoration: const InputDecoration(
                                    labelText: "Email",
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Password field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              // Forgot Password Link
                              GestureDetector(
                                onTap: () {
                                  NavigationHelper.navigateTo(
                                    context,
                                    const ForgotPasswordScreen(),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A4D2C),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF000900),
                                        Color(0xFF026A02),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account ? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _goToSignup,
                                    child: const Text(
                                      "Sign up",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A4D2C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Position the mango image on top of the white container
                        Positioned(
                          top: -80, // Adjusted position for larger image
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              AssetPaths.mango,
                              width: 380, // Increased size
                              height: 280, // Increased size
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Error message (if any)
                    if (authProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          authProvider.error!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
