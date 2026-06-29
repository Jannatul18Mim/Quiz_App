import 'package:cloud_firestore/cloud_firestore.dart';

class QuizFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadQuizToFirestore({
    required String className,
    required String subjectName,
    required String quizTitle,
    required int duration,
    required List<Map<String, dynamic>> questionsList,
  }) async {
    try {
      DocumentReference quizDocRef = _firestore.collection('quizzes').doc();

      await quizDocRef.set({
        'quizId': quizDocRef.id,
        'class': className,
        'subject': subjectName,
        'title': quizTitle,
        'durationInMinutes': duration,
        'questions': questionsList,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Store Successfully! ID: ${quizDocRef.id}");
    } catch (e) {
      print("Error: $e");
      rethrow; // কোনো এরর হলে তা যেন ইউজার ইন্টারফেসেও হ্যান্ডেল করা যায়
    }
  }
}
