import 'package:flutter/material.dart';
import 'package:flutter_application_1/dashboard.dart';
import 'package:flutter_application_1/authentication/auth_screen.dart'; // <--- ADD THIS IMPORT

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF7F9FC,
      ), // Light background color from design
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60), // Spacing for status bar
            // Screen Title
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F2C),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Avatar (Semi-circle design wrapper or alternative representation)
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD54F), // Amber background color
                ),
                child: ClipOval(
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.brown[400],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name & Email
            const Text(
              'Jannatul Mim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1F2C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'jannatul.mim@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // Profile Options Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.edit,
                    iconColor: Colors.orange,
                    iconBgColor: Colors.orange[50]!,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildProfileTile(
                    icon: Icons.settings,
                    iconColor: Colors.teal,
                    iconBgColor: Colors.teal[50]!,
                    title: 'Settings',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildProfileTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue[50]!,
                    title: 'Privacy Policy',
                    subtitle: 'Control data & permissions',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildProfileTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.blueGrey,
                    iconBgColor: Colors.yellow[50]!,
                    title: 'About Us',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        // This clears the navigation stack and pushes the AuthScreen
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ), // Replace with your actual Sign-In class name if different
                          (route) =>
                              false, // This line removes all previous screens from history
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper builder widget for modern look list items
  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F2C),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
}
