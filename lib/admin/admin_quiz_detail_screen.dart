import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminQuizDetailScreen extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const AdminQuizDetailScreen({
    super.key,
    required this.quizId,
    required this.quizData,
  });

  @override
  State<AdminQuizDetailScreen> createState() => _AdminQuizDetailScreenState();
}

class _AdminQuizDetailScreenState extends State<AdminQuizDetailScreen> {
  late List<dynamic> _questions;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questions = List<dynamic>.from(widget.quizData['questions'] ?? []);
  }

  Future<void> _removeQuestion(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Question'),
          content: const Text('Delete this question from the quiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _questions.removeAt(index);
      _isSaving = true;
    });

    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .update({'questions': _questions});

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _deleteQuiz() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Quiz'),
          content: const Text('This will remove the entire quiz permanently.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .delete();

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showAddQuestionDialog() {
    final questionController = TextEditingController();
    final optionsControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    int correctIndex = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Question'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                'Options:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    controller: optionsControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButton<int>(
                    value: correctIndex,
                    items: List.generate(
                      4,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text('Correct Answer: Option ${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          correctIndex = value;
                        });
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (questionController.text.isEmpty ||
                  optionsControllers.any((c) => c.text.isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final newQuestion = {
                'text': questionController.text,
                'options': [
                  optionsControllers[0].text,
                  optionsControllers[1].text,
                  optionsControllers[2].text,
                  optionsControllers[3].text,
                ],
                'correctOptionIndex': correctIndex,
              };

              setState(() {
                _questions.add(newQuestion);
                _isSaving = true;
              });

              await FirebaseFirestore.instance
                  .collection('quizzes')
                  .doc(widget.quizId)
                  .update({'questions': _questions});

              setState(() {
                _isSaving = false;
              });

              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.quizData['title'] ?? 'Untitled Quiz';
    final className = widget.quizData['class'] ?? 'N/A';
    final subject = widget.quizData['subject'] ?? 'N/A';
    final duration =
        widget.quizData['durationInMinutes'] ?? widget.quizData['time'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: const Text(
          'Quiz Details',
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111E38),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Class: $className',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subject: $subject',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: $duration min',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Questions: ${_questions.length}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Question Bank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111E38),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_questions.length}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  onPressed: () {
                    _showAddQuestionDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_questions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text('No questions found for this quiz.'),
              )
            else
              ..._questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value as Map<String, dynamic>;
                final options = List<String>.from(question['options'] ?? []);
                final correctIndex = question['correctOptionIndex'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Q${index + 1}: ${question['text'] ?? 'No question text'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF111E38),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: _isSaving
                                ? null
                                : () => _removeQuestion(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...options.asMap().entries.map((optionEntry) {
                        final optionIndex = optionEntry.key;
                        final optionText = optionEntry.value;
                        final isCorrect = optionIndex == correctIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isCorrect
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: 18,
                                color: isCorrect
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[500],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    color: isCorrect
                                        ? const Color(0xFF111E38)
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _deleteQuiz,
                child: const Text(
                  'Delete Quiz',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
