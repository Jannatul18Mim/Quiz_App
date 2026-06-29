import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _classController = TextEditingController();
  final _chapterController = TextEditingController();
  final _subjectController = TextEditingController();
  final _timeController = TextEditingController(text: '30');

  List<Map<String, dynamic>> _questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Details
            _buildInputField(
              'Quiz Title',
              'e.g., Class 6 - English Practice',
              _titleController,
            ),
            _buildInputField(
              'Class',
              'e.g., 6, 7, 8, 9-10, 11-12',
              _classController,
            ),
            _buildInputField(
              'Chapter',
              'e.g., Chapter 1, Unit 2',
              _chapterController,
            ),
            _buildInputField(
              'Subject',
              'e.g., English, Mathematics',
              _subjectController,
            ),
            _buildInputField(
              'Time (minutes)',
              'e.g., 30',
              _timeController,
              isNumeric: true,
            ),
            const SizedBox(height: 24),

            // Questions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions (${_questions.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111E38),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  onPressed: _addQuestion,
                  child: const Text(
                    '+ Add Question',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Questions List
            ..._questions.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> question = entry.value;
              return _buildQuestionCard(index, question);
            }).toList(),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                onPressed: _saveQuiz,
                child: const Text(
                  'Save Quiz to Firestore',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111E38),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111E38),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  setState(() => _questions.removeAt(index));
                },
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => _questions[index]['text'] = value,
            decoration: InputDecoration(
              hintText: 'Question text',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),

          // Options
          ...List.generate(4, (optionIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Radio<int>(
                      value: optionIndex,
                      groupValue: question['correctOptionIndex'] ?? 0,
                      onChanged: (value) {
                        setState(
                          () => _questions[index]['correctOptionIndex'] = value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        if (_questions[index]['options'] == null) {
                          _questions[index]['options'] = [];
                        }
                        while (_questions[index]['options']!.length <=
                            optionIndex) {
                          _questions[index]['options']!.add('');
                        }
                        _questions[index]['options']![optionIndex] = value;
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Option ${String.fromCharCode(65 + optionIndex)}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'text': '',
        'options': ['', '', '', ''],
        'correctOptionIndex': 0,
        'marks': 1,
      });
    });
  }

  void _saveQuiz() async {
    if (_titleController.text.isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields and add at least one question',
          ),
        ),
      );
      return;
    }

    try {
      final quizData = {
        'title': _titleController.text,
        'class': _classController.text,
        'chapter': _chapterController.text,
        'subject': _subjectController.text,
        'time': int.tryParse(_timeController.text) ?? 30,
        'questions': _questions,
        'createdAt': DateTime.now(),
        'createdBy': 'admin',
      };

      await _firestore.collection('quizzes').add(quizData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz saved to Firestore successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
