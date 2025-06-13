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

  const FarmDetailsScreen({Key? key, required this.farmId}) : super(key: key);

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
      final farm = farmProvider.farms.firstWhere(
        (farm) => farm.id == widget.farmId,
      );
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

      await farmProvider.updateFarm(updatedFarm);

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Farm Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          final farm = farmProvider.selectedFarm;

          if (farm == null) {
            return const Center(child: Text('Farm not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farm Overview Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.agriculture,
                                color: AppColors.primaryGreen,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    farm.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${farm.size} acres',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location Details
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.location_city,
                          label: 'District',
                          value: farm.district,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.location_on,
                          label: 'Village',
                          value: farm.village,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Farm Statistics
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Farm Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Active Seasons',
                          value:
                              farmProvider.seasons
                                  .where((s) => s.farmId == farm.id)
                                  .length
                                  .toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.note,
                          label: 'Farm Notes',
                          value:
                              farmProvider.notes
                                  .where((n) => n.farmId == farm.id)
                                  .length
                                  .toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Select Farm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      NavigationHelper.navigateToReplacement(
                        context,
                        const DashboardScreen(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Go to Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
