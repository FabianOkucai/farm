import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/strings.dart';
import '../../../core/models/farm.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/navigation_helper.dart';
// import '../../providers/auth_provider.dart';
import '../../../core/utils/local_storage.dart';
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
  final _farmerNameController = TextEditingController(); // 🆕 Add farmer name controller

  DateTime? _selectedPlantingDate;
  bool _isFirstFarm = false; // 🆕 Track if this is first farm

  @override
  void initState() {
    super.initState();
    _checkIfFirstFarm(); // 🆕 Check farm status on init
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _plantingDateController.dispose();
    _farmerNameController.dispose(); // 🆕 Dispose farmer name controller
    super.dispose();
  }

  Future<void> _selectPlantingDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPlantingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Planting Date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (picked != null && picked != _selectedPlantingDate) {
      setState(() {
        _selectedPlantingDate = picked;
        _plantingDateController.text = picked.toIso8601String().split('T')[0];
      });
      debugPrint('📅 Selected planting date: ${_plantingDateController.text}');
    }
  }

  // 🆕 ADD METHOD to check if this is the first farm
  Future<void> _checkIfFirstFarm() async {
    final localStorage = await LocalStorage.init();
    final uuid = localStorage.getUuid();
    setState(() {
      _isFirstFarm = uuid == null || uuid.isEmpty;
    });
    debugPrint('🔍 First farm check: $_isFirstFarm');
  }

  // 🔧 UPDATE _saveFarm method
  Future<void> _saveFarm() async {
    if (_formKey.currentState!.validate()) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final localStorage = await LocalStorage.init();
      final uuid = localStorage.getUuid();

      debugPrint('🌱 Creating farm...');
      debugPrint('📍 First farm: $_isFirstFarm');
      debugPrint('🔑 Existing UUID: ${uuid != null ? '${uuid.substring(0, 8)}...' : 'none'}');

      final farm = Farm(
        id: '', // Will be assigned by server
        name: _nameController.text.trim(),
        size: double.parse(_sizeController.text.trim()),
        district: _districtController.text.trim(),
        village: _villageController.text.trim(),
        farmerId: uuid ?? '', // Will be updated with proper farmer ID from server
        plantingDate: _selectedPlantingDate!,
        currentSeasonMonth: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 🔧 Get farmer name for first farm
      String? farmerName;
      if (_isFirstFarm) {
        farmerName = _farmerNameController.text.trim();
        if (farmerName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your name for the first farm'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        debugPrint('👤 Using farmer name: $farmerName');
      }

      try {
        // 🔄 Call with proper farmer name
        final returnedUuid = await farmProvider.createFarmWithUuid(
          farm,
          uuid: uuid,
          farmerName: farmerName,
        );

        // Store UUID if it's the first farm
        if (returnedUuid != null && _isFirstFarm) {
          await localStorage.setUuid(returnedUuid);
          debugPrint('💾 Stored new farmer UUID: $returnedUuid');
        }

        if (mounted) {
          NavigationHelper.navigateToReplacement(
            context,
            widget.returnToNotes ? const FarmNotesScreen() : const DashboardScreen(),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create farm: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isFirstFarm ? 'Create Your Profile & First Farm' : Strings.farmDetails, // 🔧 Dynamic title
          style: const TextStyle(
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
              // 🆕 Show info for first farm
              if (_isFirstFarm) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This is your first farm! Please provide your name and farm details.',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🆕 FARMER NAME FIELD (only for first farm)
                _buildTextField(
                  label: 'Your Name',
                  controller: _farmerNameController,
                  icon: Icons.person_outlined,
                  validator: (value) => FormValidators.validateRequired(
                    value,
                    'Your Name',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                _isFirstFarm ? 'Farm Details' : Strings.addFarm, // 🔧 Dynamic label
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),

              // Existing farm fields...
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

              // 🔧 Updated button text
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
                        : Text(
                      _isFirstFarm ? 'Create Profile & Farm' : 'Save Farm', // 🔧 Dynamic text
                      style: const TextStyle(
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

  // Existing _buildTextField method remains the same...
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
