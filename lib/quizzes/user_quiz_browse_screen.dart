import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_quiz_take_screen.dart';

class UserQuizBrowseScreen extends StatefulWidget {
  const UserQuizBrowseScreen({super.key});

  @override
  State<UserQuizBrowseScreen> createState() => _UserQuizBrowseScreenState();
}

class _UserQuizBrowseScreenState extends State<UserQuizBrowseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedClass = '';
  String selectedSubject = '';
  List<String> classes = [];
  List<String> subjects = [];
  List<String> chapters = [];
  bool _loadingClasses = true;
  Map<String, List<Map<String, dynamic>>> quizzesByChapter = {};
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allQuizDocs = [];

  String _normalizeFirestoreValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _normalizeClassKey(dynamic value) {
    var classText = _normalizeFirestoreValue(value).toLowerCase();
    classText = classText.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
    classText = classText.replaceFirst(
      RegExp(r'^class\s*', caseSensitive: false),
      '',
    );
    return classText.trim();
  }

  String _displayClassName(String rawValue) {
    final normalized = _normalizeClassKey(rawValue);
    if (normalized.isEmpty) return '';
    if (RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'class $normalized';
    }
    return _normalizeFirestoreValue(rawValue);
  }

  String _normalizeSubjectKey(dynamic value) {
    return _normalizeFirestoreValue(value).toLowerCase();
  }

  DateTime _createdAtFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String)
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final quizzesSnapshot = await _firestore.collection('quizzes').get();
      _allQuizDocs = quizzesSnapshot.docs
          .cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
      final classMap = <String, String>{};
      for (var doc in _allQuizDocs) {
        final data = doc.data();
        final rawClass = _normalizeFirestoreValue(data['class']);
        final key = _normalizeClassKey(rawClass);
        if (key.isNotEmpty) {
          classMap.putIfAbsent(key, () => _displayClassName(rawClass));
        }
      }
      if (mounted) {
        setState(() {
          classes = classMap.values.toList()..sort();
          _loadingClasses = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading classes: $e");
    }
  }

  Future<void> _loadSubjects(String className) async {
    try {
      final normalizedClass = _normalizeClassKey(className);
      final subjectMap = <String, String>{};
      for (var doc in _allQuizDocs) {
        final data = doc.data();
        final quizClass = _normalizeClassKey(data['class']);
        if (quizClass != normalizedClass) continue;
        final subject = _normalizeFirestoreValue(data['subject']);
        final key = _normalizeSubjectKey(subject);
        if (subject.isNotEmpty) {
          subjectMap.putIfAbsent(key, () => subject);
        }
      }
      if (mounted) {
        setState(() {
          subjects = subjectMap.values.toList()..sort();
          selectedSubject = '';
          chapters = [];
          quizzesByChapter = {};
        });
      }
    } catch (e) {
      debugPrint("Error loading subjects: $e");
    }
  }

  Future<void> _loadChaptersAndQuizzes(String className, String subject) async {
    try {
      final normalizedClass = _normalizeClassKey(className);
      final normalizedSubject = _normalizeSubjectKey(subject);
      final filteredDocs = _allQuizDocs.where((doc) {
        final data = doc.data();
        final quizClass = _normalizeClassKey(data['class']);
        final quizSubject = _normalizeSubjectKey(data['subject']);
        return quizClass == normalizedClass && quizSubject == normalizedSubject;
      }).toList();

      filteredDocs.sort((a, b) {
        final aCreated = _createdAtFromValue(a.data()['createdAt']);
        final bCreated = _createdAtFromValue(b.data()['createdAt']);
        return bCreated.compareTo(aCreated);
      });

      final chapterMap = <String, List<Map<String, dynamic>>>{};
      final chapterList = <String>{};

      for (var doc in filteredDocs) {
        final data = doc.data();
        final rawChapter = _normalizeFirestoreValue(data['chapter']);
        final chapter = rawChapter.isNotEmpty ? rawChapter : 'General';
        chapterList.add(chapter);
        chapterMap.putIfAbsent(chapter, () => []).add({
          'id': doc.id,
          'data': data,
        });
      }

      if (mounted) {
        setState(() {
          chapters = chapterList.toList()..sort();
          quizzesByChapter = chapterMap;
        });
      }
    } catch (e) {
      debugPrint("Error loading chapters and quizzes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: const Text(
          'Select Quiz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111E38),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loadingClasses
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedClass.isEmpty) ...[
                    const Text(
                      'Choose your class or category.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      children: classes.map(_buildCategoryCard).toList(),
                    ),
                  ] else if (selectedSubject.isEmpty) ...[
                    // Show subjects for selected class
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              selectedClass = '';
                              selectedSubject = '';
                              subjects = [];
                              chapters = [];
                              quizzesByChapter = {};
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedClass,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111E38),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a subject to view quizzes.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 18),
                    Column(
                      children: subjects
                          .map((subject) => _buildSubjectButton(subject))
                          .toList(),
                    ),
                  ] else ...[
                    // Show chapters for selected subject
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              selectedSubject = '';
                              chapters = [];
                              quizzesByChapter = {};
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedClass,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111E38),
                                ),
                              ),
                              Text(
                                selectedSubject,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (chapters.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Text('No quizzes available for this subject.'),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: chapters.map((chapter) {
                          final quizzes = quizzesByChapter[chapter] ?? [];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF5C46BD,
                                  ).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF5C46BD),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        chapter,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111E38),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2563EB,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${quizzes.length} quiz${quizzes.length != 1 ? 'zes' : ''}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: quizzes.map((quiz) {
                                  return _buildQuizCard(
                                    quiz['id'],
                                    quiz['data'],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryCard(String className) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedClass = className;
          selectedSubject = '';
          subjects = [];
          chapters = [];
          quizzesByChapter = {};
        });
        _loadSubjects(className);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.menu_book,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              className,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111E38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectButton(String subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedSubject = subject;
            chapters = [];
            quizzesByChapter = {};
          });
          _loadChaptersAndQuizzes(selectedClass, subject);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111E38),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(String quizId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['title'] ?? 'Quiz',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF111E38),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${data['durationInMinutes'] ?? 30} min',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.help_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                'Questions: ${(data['questions'] as List?)?.length ?? 0}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 180, 199, 239),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserQuizTakeScreen(quizId: quizId, quizData: data),
                  ),
                );
              },
              child: const Text(
                'Start Quiz',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
