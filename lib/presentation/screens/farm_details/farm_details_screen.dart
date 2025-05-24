import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/strings.dart';
import '../../../core/models/farm.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../dashboard/dashboard_screen.dart';
import '../../../core/utils/form_validators.dart';

class FarmDetailsScreen extends StatefulWidget {
  final String farmId;

  const FarmDetailsScreen({
    Key? key,
    required this.farmId,
  }) : super(key: key);

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _plantingDateController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isEditing = false;
  DateTime? _selectedPlantingDate;

  @override
  void initState() {
    super.initState();
    _loadFarmDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _plantingDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmDetails() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    try {
      final farm =
          farmProvider.farms.firstWhere((farm) => farm.id == widget.farmId);
      _populateFields(farm);
    } catch (e) {
      await farmProvider.selectFarm(widget.farmId);
      if (farmProvider.selectedFarm != null) {
        _populateFields(farmProvider.selectedFarm!);
      }
    }
  }

  void _populateFields(Farm farm) {
    _nameController.text = farm.name;
    _sizeController.text = farm.size.toString();
    _districtController.text = farm.district;
    _villageController.text = farm.village;
    _plantingDateController.text =
        farm.plantingDate.toIso8601String().split('T')[0];
    _selectedPlantingDate = farm.plantingDate;
    _notesController.text = 'Additional notes about the farm...';
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
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

  Future<void> _saveFarmDetails() async {
    if (_formKey.currentState!.validate()) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);

      if (farmProvider.selectedFarm == null) return;

      final updatedFarm = farmProvider.selectedFarm!.copyWith(
        name: _nameController.text.trim(),
        size: double.parse(_sizeController.text.trim()),
        district: _districtController.text.trim(),
        village: _villageController.text.trim(),
        plantingDate: _selectedPlantingDate!,
      );

      await farmProvider.updateFarm(farmProvider.selectedFarm!.id, updatedFarm);

      if (mounted) {
        _toggleEditing();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farm details updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          Strings.farmDetails,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            NavigationHelper.navigateToReplacement(
              context,
              const DashboardScreen(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: AppColors.primaryGreen,
            ),
            onPressed: _isEditing ? _toggleEditing : _toggleEditing,
          ),
        ],
      ),
      body: farmProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : farmProvider.selectedFarm == null
              ? const Center(child: Text('Farm not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Farm Image
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryLightGreen.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/mango.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: _isEditing
                                ? Center(
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        // Add image picker functionality
                                      },
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Farm Details Section
                        _buildSectionTitle('Farm Information'),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: Strings.farmName,
                          controller: _nameController,
                          isEnabled: _isEditing,
                          validator: (value) =>
                              value!.isEmpty ? 'Farm name is required' : null,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Farm Size (hectares)',
                          controller: _sizeController,
                          keyboardType: TextInputType.number,
                          isEnabled: _isEditing,
                          validator: (value) =>
                              FormValidators.validateNumber(value, 'Farm Size'),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'District',
                          controller: _districtController,
                          isEnabled: _isEditing,
                          validator: (value) =>
                              value!.isEmpty ? 'District is required' : null,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Village',
                          controller: _villageController,
                          isEnabled: _isEditing,
                          validator: (value) =>
                              value!.isEmpty ? 'Village is required' : null,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Planting Date',
                          controller: _plantingDateController,
                          isEnabled: _isEditing,
                          readOnly: true,
                          onTap: _isEditing ? _selectPlantingDate : null,
                          validator: (value) => value!.isEmpty
                              ? 'Planting date is required'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Farm Statistics Section
                        _buildSectionTitle('Farm Statistics'),
                        const SizedBox(height: 16),

                        _buildStatisticsRow(),
                        const SizedBox(height: 24),

                        // Notes Section
                        _buildSectionTitle('Notes'),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Additional Notes',
                          controller: _notesController,
                          maxLines: 4,
                          isEnabled: _isEditing,
                        ),
                        const SizedBox(height: 32),

                        // Save Button (only visible in edit mode)
                        if (_isEditing)
                          CustomButton(
                            text: 'Save Changes',
                            onPressed: _saveFarmDetails,
                            isLoading: farmProvider.isLoading,
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Seasons',
            value: '3',
            icon: Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Notes',
            value: '12',
            icon: Icons.note,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Tasks',
            value: '8',
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryGreen,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
