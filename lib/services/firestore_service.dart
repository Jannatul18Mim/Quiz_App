import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== QUIZ OPERATIONS =====

  /// Upload a quiz to Firestore
  static Future<String> uploadQuiz({
    required String title,
    required String className,
    required String chapter,
    required String subject,
    required int timeLimit,
    required List<Map<String, dynamic>> questions,
    required String createdBy,
  }) async {
    try {
      final docRef = await _firestore.collection('quizzes').add({
        'title': title,
        'class': className,
        'chapter': chapter,
        'subject': subject,
        'timeLimit': timeLimit,
        'questions': questions,
        'createdBy': createdBy,
        'createdAt': DateTime.now(),
      });
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all quizzes
  static Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    try {
      final querySnapshot = await _firestore.collection('quizzes').get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get quizzes by class
  static Future<List<Map<String, dynamic>>> getQuizzesByClass(
    String className,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('quizzes')
          .where('class', isEqualTo: className)
          .get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get quizzes by subject
  static Future<List<Map<String, dynamic>>> getQuizzesBySubject(
    String subject,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('quizzes')
          .where('subject', isEqualTo: subject)
          .get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get quiz by ID
  static Future<Map<String, dynamic>?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ===== QUIZ ATTEMPT OPERATIONS =====

  /// Record a quiz attempt
  static Future<void> recordQuizAttempt({
    required String studentId,
    required String studentName,
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required String timeUsed,
    required List<String> answers,
  }) async {
    try {
      await _firestore.collection('quiz_attempts').add({
        'studentId': studentId,
        'studentName': studentName,
        'quizId': quizId,
        'quizTitle': quizTitle,
        'score': score,
        'totalQuestions': totalQuestions,
        'timeUsed': timeUsed,
        'answers': answers,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get all attempts for a student
  static Future<List<Map<String, dynamic>>> getStudentAttempts(
    String studentId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('quiz_attempts')
          .where('studentId', isEqualTo: studentId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get all attempts
  static Future<List<Map<String, dynamic>>> getAllAttempts() async {
    try {
      final querySnapshot = await _firestore
          .collection('quiz_attempts')
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ===== USER OPERATIONS =====

  /// Add a user
  static Future<void> addUser({
    required String name,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').add({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
        'attempts': 0,
        'totalMarks': 0,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a user
  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user attempt count
  static Future<void> updateUserAttempts(String userId, int attempts) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'attempts': attempts,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ===== ANALYTICS OPERATIONS =====

  /// Get quiz analytics
  static Future<Map<String, dynamic>> getQuizAnalytics(String quizId) async {
    try {
      final attempts = await _firestore
          .collection('quiz_attempts')
          .where('quizId', isEqualTo: quizId)
          .get();

      double totalScore = 0;
      int totalAttempts = attempts.docs.length;

      for (var doc in attempts.docs) {
        final data = doc.data();
        totalScore += (data['score'] ?? 0).toDouble();
      }

      double averageScore = totalAttempts > 0
          ? (totalScore / totalAttempts)
          : 0;

      return {'totalAttempts': totalAttempts, 'averageScore': averageScore};
    } catch (e) {
      rethrow;
    }
  }

  /// Get all students' analytics
  static Future<List<Map<String, dynamic>>> getAllStudentAnalytics() async {
    try {
      final users = await _firestore.collection('users').get();
      final List<Map<String, dynamic>> analytics = [];

      for (var userDoc in users.docs) {
        final userData = userDoc.data();
        final attempts = await _firestore
            .collection('quiz_attempts')
            .where('studentId', isEqualTo: userDoc.id)
            .get();

        double totalScore = 0;
        int totalAttempts = attempts.docs.length;

        for (var attemptDoc in attempts.docs) {
          final data = attemptDoc.data();
          totalScore += (data['score'] ?? 0).toDouble();
        }

        double averageScore = totalAttempts > 0
            ? (totalScore / totalAttempts)
            : 0;

        analytics.add({
          'studentId': userDoc.id,
          'studentName': userData['name'] ?? 'N/A',
          'email': userData['email'] ?? 'N/A',
          'totalAttempts': totalAttempts,
          'averageScore': averageScore,
        });
      }

      return analytics;
    } catch (e) {
      rethrow;
    }
  }
}
