import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_quiz_take_screen.dart';

class JoinQuizScreen extends StatefulWidget {
  const JoinQuizScreen({super.key});

  @override
  State<JoinQuizScreen> createState() => _JoinQuizScreenState();
}

class _JoinQuizScreenState extends State<JoinQuizScreen> {
  final _joinCodeController = TextEditingController();
  bool _isJoining = false;
  String? _error;

  String _extractJoinCode(String rawInput) {
    final input = rawInput.trim();
    if (input.isEmpty) return '';
    if (input.contains('/')) {
      final uri = Uri.tryParse(input);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
      return input.split('/').last;
    }
    return input;
  }

  Future<void> _joinQuiz() async {
    setState(() {
      _error = null;
      _isJoining = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Please log in before joining a quiz.';
        _isJoining = false;
      });
      return;
    }

    final code = _extractJoinCode(_joinCodeController.text);
    if (code.isEmpty) {
      setState(() {
        _error = 'Enter a valid join link or code.';
        _isJoining = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('joinCode', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _error = 'No quiz found for this join code.';
          _isJoining = false;
        });
        return;
      }

      final quizDoc = querySnapshot.docs.first;
      final quizData = quizDoc.data();
      final questions = quizData['questions'] as List? ?? [];
      if (questions.isEmpty) {
        setState(() {
          _error = 'This quiz has no questions yet.';
          _isJoining = false;
        });
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UserQuizTakeScreen(quizId: quizDoc.id, quizData: quizData),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Unable to join quiz. Try again later.';
        _isJoining = false;
      });
    }
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: const Text(
          'Join Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111E38),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the quiz join code or full link below.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _joinCodeController,
              decoration: InputDecoration(
                labelText: 'Join code or link',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isJoining ? null : _joinQuiz,
                child: _isJoining
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Join Quiz',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'How it works',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Get the join code from the quiz creator.\n'
              '2. Paste the code or full link here.\n'
              '3. Complete the quiz and your result will be saved.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
