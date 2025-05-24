import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/strings.dart';
import '../../../core/models/farm.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farm_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../farm_notes/farm_notes_screen.dart';

class AddFarmScreen extends StatefulWidget {
  final bool returnToNotes;

  const AddFarmScreen({
    Key? key,
    this.returnToNotes = false,
  }) : super(key: key);

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _plantingDateController = TextEditingController();
  DateTime? _selectedPlantingDate;

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _plantingDateController.dispose();
    super.dispose();
  }

  Future<void> _selectPlantingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPlantingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedPlantingDate) {
      setState(() {
        _selectedPlantingDate = picked;
        _plantingDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveFarm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);

      if (authProvider.user == null) return;

      final farm = Farm(
        id: '', // Will be assigned by the server
        name: _nameController.text.trim(),
        size: double.parse(_sizeController.text.trim()),
        district: _districtController.text.trim(),
        village: _villageController.text.trim(),
        farmerId: authProvider.user!.id,
        plantingDate: _selectedPlantingDate!,
        currentSeasonMonth: 1, // Starting with month 1
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await farmProvider.createFarm(farm);

      if (mounted) {
        NavigationHelper.navigateToReplacement(
          context,
          widget.returnToNotes
              ? const FarmNotesScreen()
              : const DashboardScreen(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          Strings.farmDetails,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            NavigationHelper.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.addFarm,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: Strings.farmName,
                controller: _nameController,
                icon: Icons.agriculture_outlined,
                validator: (value) => FormValidators.validateRequired(
                  value,
                  Strings.farmName,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Farm Size (hectares)',
                controller: _sizeController,
                icon: Icons.square_foot_outlined,
                keyboardType: TextInputType.number,
                validator: (value) => FormValidators.validateNumber(
                  value,
                  'Farm Size',
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'District',
                controller: _districtController,
                icon: Icons.location_city_outlined,
                validator: (value) => FormValidators.validateRequired(
                  value,
                  'District',
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Village',
                controller: _villageController,
                icon: Icons.home_outlined,
                validator: (value) => FormValidators.validateRequired(
                  value,
                  'Village',
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Planting Date',
                controller: _plantingDateController,
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _selectPlantingDate,
                validator: (value) => FormValidators.validateRequired(
                  value,
                  'Planting Date',
                ),
              ),
              const SizedBox(height: 32),
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
                    onPressed: farmProvider.isLoading ? null : _saveFarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: farmProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Farm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade700,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primaryGreen,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
