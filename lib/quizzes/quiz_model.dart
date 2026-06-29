class QuizModel {
  String id;
  String title;
  String time;
  String className;
  String subjectSlug;
  String joinCode;
  bool showScoreOnSubmit;
  int graceSeconds;
  List<QuestionModel> questions;

  QuizModel({
    required this.id,
    required this.title,
    required this.time,
    required this.className,
    required this.subjectSlug,
    this.joinCode = '',
    this.showScoreOnSubmit = true,
    this.graceSeconds = 60,
    List<QuestionModel>? questions,
  }) : this.questions = questions ?? [];
}

class QuestionModel {
  String questionText;
  int marks;
  List<String> options;
  int correctOptionIndex;

  QuestionModel({
    this.questionText = '',
    this.marks = 1,
    List<String>? options,
    this.correctOptionIndex = 0,
  }) : this.options =
           options ?? ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
}

// গ্লোবাল লিস্ট (ডাটাবেজ বা প্রোভাইডার ছাড়া টেস্ট করার জন্য)
List<QuizModel> globalQuizList = [];
