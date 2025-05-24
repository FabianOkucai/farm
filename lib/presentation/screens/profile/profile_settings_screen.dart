import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/assets_path.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/models/season.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/navigation_bar.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../farm_notes/farm_notes_screen.dart';
import '../seasons/seasons_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  File? _profileImage;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.fullName;
      _emailController.text = authProvider.user!.email;
      _phoneController.text = authProvider.user!.phone;
      _districtController.text = authProvider.user!.district;
      _villageController.text = authProvider.user!.village;
    }
  }

  void _onNavigationTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        NavigationHelper.navigateToReplacement(
            context, const DashboardScreen());
        break;
      case 1:
        NavigationHelper.navigateToReplacement(context, const SeasonsScreen());
        break;
      case 2:
        NavigationHelper.navigateToReplacement(
            context, const FarmNotesScreen());
        break;
      case 3:
        // Already on profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Image Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display Name',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        enabled: false,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          fillColor: Color(0xFFF5F5F5),
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
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
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // District Field
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
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
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Village Field
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
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
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Password',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextFormField(
                        enabled: false,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: '••••••••',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          fillColor: Color(0xFFF5F5F5),
                          filled: true,
                          suffixIcon: Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Number of Farms',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: farmProvider.farms.length.toString(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          fillColor: Color(0xFFF5F5F5),
                          filled: true,
                        ),
                        items: [farmProvider.farms.length.toString()]
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Current Season',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: farmProvider.seasons
                            .where((s) => s.status == SeasonStatus.active)
                            .length
                            .toString(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                          fillColor: Color(0xFFF5F5F5),
                          filled: true,
                        ),
                        items: [
                          farmProvider.seasons
                              .where((s) => s.status == SeasonStatus.active)
                              .length
                              .toString()
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: null,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade700, Colors.red.shade900],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            await authProvider.logout();
                            if (context.mounted) {
                              NavigationHelper.navigateToReplacement(
                                context,
                                const LoginScreen(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                Strings.logout,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Save Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF000900), Color(0xFF026A02)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF026A02).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.save_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.updateProfile(
        displayName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        district: _districtController.text.trim(),
        village: _villageController.text.trim(),
        profileImage: _profileImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }
}
