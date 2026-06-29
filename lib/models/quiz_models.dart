class QuizAttempt {
  final String id;
  final String studentId;
  final String studentName;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final String timeUsed;
  final DateTime timestamp;
  final List<String> answers;

  QuizAttempt({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.timeUsed,
    required this.timestamp,
    required this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeUsed': timeUsed,
      'timestamp': timestamp,
      'answers': answers,
    };
  }

  factory QuizAttempt.fromMap(String id, Map<String, dynamic> map) {
    return QuizAttempt(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      quizId: map['quizId'] ?? '',
      quizTitle: map['quizTitle'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timeUsed: map['timeUsed'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      answers: List<String>.from(map['answers'] ?? []),
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final String className;
  final String chapter;
  final String subject;
  final int time;
  final List<Map<String, dynamic>> questions;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.className,
    required this.chapter,
    required this.subject,
    required this.time,
    required this.questions,
    required this.createdAt,
  });

  factory QuizModel.fromMap(String id, Map<String, dynamic> map) {
    return QuizModel(
      id: id,
      title: map['title'] ?? '',
      className: map['class'] ?? '',
      chapter: map['chapter'] ?? '',
      subject: map['subject'] ?? '',
      time: map['time'] ?? 30,
      questions: List<Map<String, dynamic>>.from(map['questions'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class QuestionModel {
  final String questionText;
  final int marks;
  final List<String> options;
  final int correctOptionIndex;

  QuestionModel({
    required this.questionText,
    required this.marks,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'marks': marks,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      questionText: map['questionText'] ?? '',
      marks: map['marks'] ?? 1,
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }
}
