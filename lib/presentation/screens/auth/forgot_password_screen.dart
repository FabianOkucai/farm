import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/assets_path.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.resetPassword(_emailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset link sent to your email'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );

          // Navigate back to login screen
          NavigationHelper.navigateToReplacement(context, const LoginScreen());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000900),
              Color(0xFF026A02),
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
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      "Forgot Password",
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
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 120),

                              // Instructions text
                              const Text(
                                "Enter your email address",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "We'll send you a link to reset your password",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),

                              // Email field
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
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

                              const SizedBox(height: 30),

                              // Reset Password button
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
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            "Reset Password",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Back to login link
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  "Back to Login",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A4D2C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Position the mango image on top of the white container
                        Positioned(
                          top: -100,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              AssetPaths.mango,
                              width: 220,
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Error message
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
