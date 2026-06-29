import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manage_quiz_screen.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: const Text(
          'My Quizzes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111E38),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view your quizzes'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('quizzes')
                  .where('createdBy', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final quizzes = (snapshot.data?.docs ?? []).toList();
                quizzes.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aCreated = aData['createdAt'];
                  final bCreated = bData['createdAt'];

                  DateTime aDate;
                  DateTime bDate;

                  if (aCreated is DateTime) {
                    aDate = aCreated;
                  } else if (aCreated is Timestamp) {
                    aDate = aCreated.toDate();
                  } else {
                    aDate = DateTime.fromMillisecondsSinceEpoch(0);
                  }

                  if (bCreated is DateTime) {
                    bDate = bCreated;
                  } else if (bCreated is Timestamp) {
                    bDate = bCreated.toDate();
                  } else {
                    bDate = DateTime.fromMillisecondsSinceEpoch(0);
                  }

                  return bDate.compareTo(aDate);
                });

                if (quizzes.isEmpty) {
                  return const Center(child: Text('No quizzes created yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quizDoc = quizzes[index];
                    final quiz = quizDoc.data() as Map<String, dynamic>;

                    return Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quiz['title'] ?? 'Untitled Quiz',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111E38),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Class: ${quiz['class'] ?? 'N/A'} | Subject: ${quiz['subject'] ?? 'N/A'} | ${quiz['durationInMinutes'] ?? 30} mins',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Color(0xFF2563EB),
                                ),
                                tooltip: 'Copy join link',
                                onPressed: () {
                                  final code = quiz['joinCode'] ?? '';
                                  if (code.isNotEmpty) {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            'https://quizapp.example.com/j/$code',
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Join link copied'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 4),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageQuizScreen(quizId: quizDoc.id),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2563EB),
                                ),
                                child: const Text('Manage'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete Quiz'),
                                        content: const Text(
                                          'Are you sure you want to delete this quiz?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmed == true) {
                                    await _firestore
                                        .collection('quizzes')
                                        .doc(quizDoc.id)
                                        .delete();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
