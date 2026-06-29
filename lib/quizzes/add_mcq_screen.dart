import 'package:flutter/material.dart';
import 'quiz_model.dart';

class AddMcqScreen extends StatefulWidget {
  final QuizModel quiz;
  final QuestionModel? question;
  final int? questionIndex;

  const AddMcqScreen({
    super.key,
    required this.quiz,
    this.question,
    this.questionIndex,
  });

  @override
  State<AddMcqScreen> createState() => _AddMcqScreenState();
}

class _AddMcqScreenState extends State<AddMcqScreen> {
  final _questionController = TextEditingController();
  final _marksController = TextEditingController(text: "1");
  List<TextEditingController> _optionControllers = [
    TextEditingController(text: "Option 1"),
    TextEditingController(text: "Option 2"),
    TextEditingController(text: "Option 3"),
    TextEditingController(text: "Option 4"),
  ];
  int _correctIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _questionController.text = widget.question!.questionText;
      _marksController.text = widget.question!.marks.toString();
      _correctIndex = widget.question!.correctOptionIndex;
      _optionControllers = widget.question!.options
          .map((option) => TextEditingController(text: option))
          .toList();
      if (_optionControllers.length < 2) {
        _optionControllers = [
          TextEditingController(text: 'Option 1'),
          TextEditingController(text: 'Option 2'),
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: Text(
          'Manage: ${widget.quiz.title}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.question != null
                        ? 'Q${widget.questionIndex! + 1}. Edit question'
                        : 'Q${widget.quiz.questions.length + 1}. New question',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111E38),
                    ),
                  ),
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter question text here',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Marks: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _marksController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // অপশন লিস্ট জেনারেটর
                  Column(
                    children: List.generate(_optionControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: _correctIndex,
                              activeColor: const Color(0xFF5C46BD),
                              onChanged: (val) =>
                                  setState(() => _correctIndex = val!),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _optionControllers[index],
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // অপশন প্লাস এবং রিমুভ রো বাটন
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2FA),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _optionControllers.add(
                              TextEditingController(
                                text: "Option ${_optionControllers.length + 1}",
                              ),
                            );
                          });
                        },
                        child: const Text(
                          '+ option',
                          style: TextStyle(color: Color(0xFF5C46BD)),
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () {
                          if (_optionControllers.length > 2) {
                            setState(() {
                              _optionControllers.removeLast();
                              if (_correctIndex >= _optionControllers.length) {
                                _correctIndex = _optionControllers.length - 1;
                              }
                            });
                          }
                        },
                        child: const Text(
                          'Remove',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                onPressed: () {
                  if (_questionController.text.isEmpty) return;

                  final updatedQuestion = QuestionModel(
                    questionText: _questionController.text,
                    marks: int.tryParse(_marksController.text) ?? 1,
                    options: _optionControllers.map((c) => c.text).toList(),
                    correctOptionIndex: _correctIndex,
                  );

                  if (widget.questionIndex != null) {
                    widget.quiz.questions[widget.questionIndex!] =
                        updatedQuestion;
                  } else {
                    widget.quiz.questions.add(updatedQuestion);
                  }

                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Save changes',
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
}
