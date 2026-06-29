import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_mcq_screen.dart';
import 'quiz_model.dart';

class ManageQuizScreen extends StatefulWidget {
  final String? quizId;
  final QuizModel? quiz;

  const ManageQuizScreen({super.key, this.quizId, this.quiz})
    : assert(
        quizId != null || quiz != null,
        'Either quizId or quiz must be provided',
      );

  @override
  State<ManageQuizScreen> createState() => _ManageQuizScreenState();
}

class _ManageQuizScreenState extends State<ManageQuizScreen> {
  late bool _showScore;
  final _graceController = TextEditingController();
  QuizModel? _quizModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _quizModel = widget.quiz;
      _showScore = _quizModel!.showScoreOnSubmit;
      _graceController.text = _quizModel!.graceSeconds.toString();
      _isLoading = false;
    } else if (widget.quizId != null) {
      _loadQuizFromFirestore();
    }
  }

  Future<void> _loadQuizFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId!)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final questionsData = (data['questions'] as List<dynamic>?) ?? [];
        final questions = questionsData.map((questionItem) {
          final questionMap = Map<String, dynamic>.from(questionItem as Map);
          return QuestionModel(
            questionText: questionMap['questionText'] ?? '',
            marks: questionMap['marks'] ?? 1,
            options: List<String>.from(
              (questionMap['options'] as List<dynamic>?)?.map(
                    (e) => e.toString(),
                  ) ??
                  [],
            ),
            correctOptionIndex: questionMap['correctOptionIndex'] ?? 0,
          );
        }).toList();

        _quizModel = QuizModel(
          id: doc.id,
          title: data['title'] ?? 'Untitled',
          time: data['durationInMinutes']?.toString() ?? '30',
          className: data['class'] ?? '',
          subjectSlug: data['subject'] ?? '',
          joinCode: data['joinCode'] ?? '',
          showScoreOnSubmit: data['showScoreOnSubmit'] ?? false,
          graceSeconds: data['graceSeconds'] ?? 0,
          questions: questions,
        );

        _showScore = _quizModel!.showScoreOnSubmit;
        _graceController.text = _quizModel!.graceSeconds.toString();
      }
    } catch (e) {
      debugPrint('Error loading quiz: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateJoinCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  Future<void> _ensureJoinCodeExists() async {
    if (_quizModel == null) return;
    if (_quizModel!.joinCode.trim().isEmpty) {
      final code = _generateJoinCode(8);
      _quizModel!.joinCode = code;
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(_quizModel!.id)
          .update({'joinCode': code});
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveQuizSettingsToFirestore() async {
    if (_quizModel == null) return;
    final grace = int.tryParse(_graceController.text) ?? 60;
    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(_quizModel!.id)
        .update({'showScoreOnSubmit': _showScore, 'graceSeconds': grace});
  }

  Future<void> _saveQuestionsToFirestore() async {
    if (_quizModel == null) return;
    final questionsData = _quizModel!.questions.map((q) {
      return {
        'questionText': q.questionText,
        'marks': q.marks,
        'options': q.options,
        'correctOptionIndex': q.correctOptionIndex,
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(_quizModel!.id)
        .update({'questions': questionsData});
  }

  Future<void> _removeQuestion(int index) async {
    if (_quizModel == null) return;
    _quizModel!.questions.removeAt(index);
    await _saveQuestionsToFirestore();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openQuestionEditor({int? index}) async {
    if (_quizModel == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMcqScreen(
          quiz: _quizModel!,
          question: index != null ? _quizModel!.questions[index] : null,
          questionIndex: index,
        ),
      ),
    );

    if (updated == true) {
      await _saveQuestionsToFirestore();
      await _loadQuizFromFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_quizModel == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Quiz not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage: ${_quizModel!.title}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111E38),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<void>(
              future: _ensureJoinCodeExists(),
              builder: (context, snapshot) {
                final joinUrl =
                    'https://quizapp.example.com/j/${_quizModel!.joinCode}';
                return Column(
                  children: [
                    _buildLinkCard('Join link', joinUrl),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // সেটিংস প্যানেল
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Show score on submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: _showScore,
                        activeColor: const Color(0xFF5C46BD),
                        onChanged: (val) => setState(() => _showScore = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Grace (sec)',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _graceController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () async {
                        _quizModel!.showScoreOnSubmit = _showScore;
                        _quizModel!.graceSeconds =
                            int.tryParse(_graceController.text) ?? 60;
                        await _saveQuizSettingsToFirestore();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings Saved!')),
                        );
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions (${_quizModel!.questions.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111E38),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _openQuestionEditor(),
                  child: const Text(
                    'Add Question',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_quizModel!.questions.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Text(
                  'No questions added yet. Tap Add Question to begin.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Column(
                children: List.generate(_quizModel!.questions.length, (index) {
                  final question = _quizModel!.questions[index];
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${index + 1}. ${question.questionText.isEmpty ? 'New question' : question.questionText}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111E38),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Marks: ${question.marks}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: List.generate(question.options.length, (
                            optionIndex,
                          ) {
                            final optionText = question.options[optionIndex];
                            final isCorrect =
                                optionIndex == question.correctOptionIndex;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 18,
                                    color: isCorrect
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey[400],
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
                          }),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _openQuestionEditor(index: index),
                              child: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _removeQuestion(index),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCard(String title, String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  url,
                  style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Join link copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}
