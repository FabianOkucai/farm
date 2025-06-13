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
import 'login_screen.dart';
import '../contact/contact_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  // Function to validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Function to handle sign up
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        district: _districtController.text.trim(),
        village: _villageController.text.trim(),
      );

      if (authProvider.user != null && mounted) {
        NavigationHelper.navigateToAndRemoveUntil(
          context,
          const DashboardScreen(),
        );
      }
    }
  }

  // Function to navigate to login screen
  void _goToLogin() {
    NavigationHelper.navigateTo(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

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
                                height: 140,
                              ), // Increased space for larger mango image
                              // Welcome text
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Sign Up your account",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Name Field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  validator: FormValidators.validateName,
                                  decoration: const InputDecoration(
                                    labelText: "Full Name",
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

                              // Phone Field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: FormValidators.validatePhone,
                                  decoration: const InputDecoration(
                                    labelText: "Phone Number (+256)",
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

                              // District Field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _districtController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'District is required';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "District",
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

                              // Village Field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _villageController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Village is required';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: "Village",
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
                                  validator: FormValidators.validatePassword,
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

                              const SizedBox(height: 15),

                              // Confirm Password field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  validator: _validateConfirmPassword,
                                  decoration: const InputDecoration(
                                    labelText: "Confirm Password",
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

                              const SizedBox(height: 25),

                              // Sign up button
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
                                    onPressed: _signUp,
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
                                      "Sign up",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Proceed to ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _goToLogin,
                                    child: const Text(
                                      "Login",
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
                              width: 280, // Increased size
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationHelper.navigateTo(context, const ContactScreen());
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.contact_phone),
      ),
    );
  }
}
