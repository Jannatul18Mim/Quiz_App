import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizResultsScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final String timeUsed;
  final List<dynamic> questions;
  final List<int?> selectedAnswers;
  final String? quizOwnerId;

  const QuizResultsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.timeUsed,
    required this.questions,
    required this.selectedAnswers,
    this.quizOwnerId,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveResultsToFirestore();
  }

  Future<void> _saveResultsToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};

      // Save quiz attempt
      await FirebaseFirestore.instance.collection('quiz_attempts').add({
        'studentId': user.uid,
        'studentName': userData['name'] ?? 'Anonymous',
        'quizId': widget.quizId,
        'quizTitle': widget.quizTitle,
        'quizOwnerId': widget.quizOwnerId ?? '',
        'score': widget.score,
        'totalQuestions': widget.totalQuestions,
        'timeUsed': widget.timeUsed,
        'answers': widget.selectedAnswers
            .map((a) => a?.toString() ?? '')
            .toList(),
        'timestamp': DateTime.now(),
      });

      if (mounted) {
        setState(() {
          _saved = true;
        });
      }
    } catch (e) {
      debugPrint("Error saving results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (widget.score / widget.totalQuestions) * 100;
    bool passed = percentage >= 60;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111E38),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Result badge
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                border: Border.all(
                  color: passed ? const Color(0xFF4CAF50) : Colors.red,
                  width: 4,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: passed ? const Color(0xFF4CAF50) : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        passed ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: passed ? const Color(0xFF4CAF50) : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Summary cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Quiz Title', widget.quizTitle),
                  const Divider(),
                  _buildSummaryRow(
                    'Your Score',
                    '${widget.score}/${widget.totalQuestions}',
                  ),
                  const Divider(),
                  _buildSummaryRow('Time Taken', widget.timeUsed),
                  const Divider(),
                  _buildSummaryRow('Passing Score', '60%'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Answer review
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Answer Review',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF111E38),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(widget.questions.length, (index) {
                    final question = widget.questions[index];
                    final selected = widget.selectedAnswers[index];
                    final correct = question['correctOptionIndex'];
                    final isCorrect = selected == correct;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? const Color(0xFF4CAF50).withOpacity(0.05)
                              : Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrect
                                ? const Color(0xFF4CAF50).withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect
                                      ? const Color(0xFF4CAF50)
                                      : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Q${index + 1}: ${question['text'] ?? question['questionText'] ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (selected != null &&
                                selected <
                                    ((question['options'] as List?)?.length ??
                                        0))
                              Text(
                                'Your answer: ${question['options'][selected]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF111E38),
                                ),
                              ),
                            if (selected != correct)
                              Text(
                                'Correct answer: ${question['options'][correct] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text(
                      'Retake Quiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111E38),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
