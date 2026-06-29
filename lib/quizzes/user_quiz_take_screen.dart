import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_results_screen.dart';

class UserQuizTakeScreen extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const UserQuizTakeScreen({
    super.key,
    required this.quizId,
    required this.quizData,
  });

  @override
  State<UserQuizTakeScreen> createState() => _UserQuizTakeScreenState();
}

class _UserQuizTakeScreenState extends State<UserQuizTakeScreen> {
  late PageController _pageController;
  int currentQuestion = 0;
  late List<int?> selectedAnswers;
  late int timeRemaining;
  late DateTime startTime;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final questions = widget.quizData['questions'] as List? ?? [];
    selectedAnswers = List<int?>.filled(questions.length, null, growable: true);
    timeRemaining = ((widget.quizData['timeLimit'] ?? 30) * 60);
    startTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          timeRemaining--;
          if (timeRemaining <= 0) {
            _submitQuiz();
          }
        });
        _startTimer();
      }
    });
  }

  void _submitQuiz() {
    final questions = widget.quizData['questions'] as List? ?? [];
    int score = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] != null &&
          selectedAnswers[i] == questions[i]['correctOptionIndex']) {
        score++;
      }
    }

    final duration = DateTime.now().difference(startTime);
    final timeUsed =
        '${duration.inMinutes}m ${(duration.inSeconds % 60).toString().padLeft(2, '0')}s';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          quizId: widget.quizId,
          quizTitle: widget.quizData['title'] ?? 'Quiz',
          quizOwnerId: widget.quizData['createdBy'] ?? '',
          score: score,
          totalQuestions: questions.length,
          timeUsed: timeUsed,
          questions: questions,
          selectedAnswers: selectedAnswers,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quizData['questions'] as List? ?? [];

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFE),
        appBar: AppBar(
          title: Text(
            widget.quizData['title'] ?? 'Quiz',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF111E38),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: timeRemaining <= 60
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: timeRemaining <= 60
                        ? Colors.red
                        : const Color(0xFF2563EB),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: timeRemaining <= 60
                          ? Colors.red
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentQuestion + 1} of ${questions.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${((currentQuestion + 1) / questions.length * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentQuestion + 1) / questions.length,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    currentQuestion = index;
                    isAnswered = selectedAnswers[index] != null;
                  });
                },
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final options = question['options'] as List? ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['text'] ??
                              question['questionText'] ??
                              'Question',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111E38),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(options.length, (optionIndex) {
                          final isSelected =
                              selectedAnswers[index] == optionIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedAnswers[index] = optionIndex;
                                  isAnswered = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF2563EB).withOpacity(0.1)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF2563EB)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        options[optionIndex] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF111E38),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentQuestion > 0)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF2563EB)),
                        ),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (currentQuestion > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                      onPressed: () {
                        if (currentQuestion == questions.length - 1) {
                          _submitQuiz();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        currentQuestion == questions.length - 1
                            ? 'Submit'
                            : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
