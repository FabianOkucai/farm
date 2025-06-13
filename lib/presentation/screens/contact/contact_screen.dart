import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get in Touch', style: AppTextStyles.heading1),
            const SizedBox(height: 24),
            _buildContactCard(
              icon: Icons.phone,
              title: 'Phone',
              content: '+256 123 456 789',
              onTap: () {
                // TODO: Implement phone call functionality
              },
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email,
              title: 'Email',
              content: 'support@farmapp.ug',
              onTap: () {
                // TODO: Implement email functionality
              },
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.location_on,
              title: 'Address',
              content: 'Kampala, Uganda\nEast Africa',
              onTap: null,
            ),
            const SizedBox(height: 24),
            const Text('Office Hours', style: AppTextStyles.heading2),
            const SizedBox(height: 16),
            _buildInfoCard('Monday - Friday', '8:00 AM - 5:00 PM'),
            const SizedBox(height: 8),
            _buildInfoCard('Saturday', '9:00 AM - 1:00 PM'),
            const SizedBox(height: 8),
            _buildInfoCard('Sunday', 'Closed'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(content, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(content, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
