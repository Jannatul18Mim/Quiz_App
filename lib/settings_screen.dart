import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  String _language = 'English';
  String _theme = 'System';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = _prefs.getString('language') ?? 'English';
      _theme = _prefs.getString('theme') ?? 'System';
      _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveLanguage(String language) async {
    await _prefs.setString('language', language);
    setState(() => _language = language);
  }

  Future<void> _saveTheme(String theme) async {
    await _prefs.setString('theme', theme);
    setState(() => _theme = theme);
  }

  Future<void> _saveNotifications(bool enabled) async {
    await _prefs.setBool('notificationsEnabled', enabled);
    setState(() => _notificationsEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111E38),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            const Text(
              'Language',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111E38),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildLanguageOption('English'),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildLanguageOption('Bangla'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Theme Section
            const Text(
              'Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111E38),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildThemeOption('Light'),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildThemeOption('Dark'),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildThemeOption('System'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notifications Section
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111E38),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enable Notifications',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111E38),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get alerts for quizzes and meetings',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (value) => _saveNotifications(value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification Types
            if (_notificationsEnabled) ...[
              const Text(
                'Notification Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111E38),
                ),
              ),
              const SizedBox(height: 12),
              _buildNotificationType(
                'Quiz Reminders',
                'Remind me before quizzes',
              ),
              const SizedBox(height: 10),
              _buildNotificationType(
                'Meeting Alerts',
                'Notify me about upcoming meetings',
              ),
              const SizedBox(height: 10),
              _buildNotificationType(
                'Result Updates',
                'Show when quiz results are ready',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        language,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111E38),
        ),
      ),
      value: language,
      groupValue: _language,
      activeColor: const Color(0xFF2563EB),
      onChanged: (value) {
        if (value != null) {
          _saveLanguage(value);
        }
      },
    );
  }

  Widget _buildThemeOption(String theme) {
    return RadioListTile<String>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        theme,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111E38),
        ),
      ),
      value: theme,
      groupValue: _theme,
      activeColor: const Color(0xFF2563EB),
      onChanged: (value) {
        if (value != null) {
          _saveTheme(value);
          // In a real app, you would apply the theme here
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Theme set to $value')));
        }
      },
    );
  }

  Widget _buildNotificationType(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111E38),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value: true,
            activeColor: const Color(0xFF2563EB),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
