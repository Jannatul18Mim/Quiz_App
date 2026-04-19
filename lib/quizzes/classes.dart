import 'package:flutter/material.dart';
import 'package:flutter_application_1/dashboard.dart';

class ClassesPage extends StatelessWidget {
  static const routeName = '/classes';

  const ClassesPage({super.key});

  Widget _buildClassCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: Colors.blue.shade700),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          // Added SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Select Class',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose your class or category.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF667085)),
                ),
                const SizedBox(height: 30),
                GridView.count(
                  shrinkWrap:
                      true, // Important for using GridView inside Column
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable grid scrolling
                  crossAxisCount: 2,
                  childAspectRatio: 1.18,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    _buildClassCard(
                      context,
                      icon: Icons.book,
                      label: 'Class 6',
                      onTap: () {},
                    ),
                    _buildClassCard(
                      context,
                      icon: Icons.book,
                      label: 'Class 7',
                      onTap: () {},
                    ),
                    _buildClassCard(
                      context,
                      icon: Icons.book,
                      label: 'Class 8',
                      onTap: () {},
                    ),
                    _buildClassCard(
                      context,
                      icon: Icons.book,
                      label: 'Class 9-10',
                      onTap: () {},
                    ),
                    _buildClassCard(
                      context,
                      icon: Icons.book,
                      label: 'Class 11-12',
                      onTap: () {},
                    ),
                    _buildClassCard(
                      context,
                      icon: Icons.description,
                      label: 'Admission Test',
                      textColor: Colors.orange.shade700,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
