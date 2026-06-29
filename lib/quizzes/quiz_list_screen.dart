import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizListScreen extends StatelessWidget {
  final String selectedClass;
  final String selectedSubject;

  const QuizListScreen({
    super.key,
    required this.selectedClass,
    required this.selectedSubject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$selectedClass: $selectedSubject"),
        backgroundColor: const Color(0xFF4A148C),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('class', isEqualTo: selectedClass)
            .where('subject', isEqualTo: selectedSubject)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading quizzes: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizDocs = snapshot.data?.docs ?? [];

          if (quizDocs.isEmpty) {
            return const Center(
              child: Text(
                'No quizzes published for this subject yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: quizDocs.length,
            itemBuilder: (context, index) {
              final quizData = quizDocs[index].data() as Map<String, dynamic>;
              final String quizTitle = quizData['title'] ?? 'Untitled Quiz';
              final int duration = quizData['durationInMinutes'] ?? 0;
              final List questions = quizData['questions'] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF5E35B1),
                    child: Icon(Icons.play_lesson, color: Colors.white),
                  ),
                  title: Text(
                    quizTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      '⏱️ $duration Mins  |  📝 ${questions.length} Questions',
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
