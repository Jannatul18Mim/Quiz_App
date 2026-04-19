import 'package:flutter/material.dart';
import 'package:flutter_application_1/quizzes/classes.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Define your pages here
  static const List<Widget> _pages = <Widget>[
    DashboardContent(), // Your current dashboard content
    ClassesPage(), // Quizzes page
    ProfilePage(), // Profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Add this to track current selection
        selectedItemColor: const Color(0xFF4A148C),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: _onItemTapped, // Don't pass context here
      ),
    );
  }
}

// Extract your existing dashboard content into a separate widget
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF4A148C),
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            width: double.infinity,
            child: const Text(
              'QuizAid',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meeting Zone
                const Text(
                  'Meeting Zone',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        'New Meeting',
                        'Start an instant room',
                        Icons.add,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCard(
                        'Join Meeting',
                        'Use meeting ID or link',
                        Icons.people,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCard(
                  'Schedule Meeting',
                  'Plan sessions ahead with students',
                  Icons.calendar_today,
                ),
                const SizedBox(height: 24),
                // Manage Quizzes
                const Text(
                  'Manage Quizzes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        'Create Quiz',
                        'Build a new question set',
                        Icons.add,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCard(
                        'My List',
                        'All created quizzes',
                        Icons.list,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCard(
                  'Reports',
                  'View performance insights',
                  Icons.bar_chart,
                ),
                const SizedBox(height: 24),
                // Study Zone
                const Text(
                  'Study Zone',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCard(
                        'Questions Bank',
                        'Practice by topic',
                        Icons.book,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCard(
                        'Results',
                        'Recent attempt history',
                        Icons.group,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Menu Section
                _buildMenuSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final List<String> menuItems = [
      'About Us',
      'FAQ',
      'Contact Us',
      'Help and Support',
      'Privacy Policy',
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          int index = entry.key;
          String title = entry.value;
          return Column(
            children: [
              ListTile(
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                ),
                onTap: () {},
              ),
              if (index < menuItems.length - 1)
                const Divider(
                  color: Colors.white12,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF5E35B1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Create placeholder pages for other tabs
class QuizzesPage extends StatelessWidget {
  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        backgroundColor: const Color(0xFF4A148C),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Quizzes Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4A148C),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Profile Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
