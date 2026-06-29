import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QuizOwnerResultsScreen extends StatefulWidget {
  const QuizOwnerResultsScreen({super.key});

  @override
  State<QuizOwnerResultsScreen> createState() => _QuizOwnerResultsScreenState();
}

class _QuizOwnerResultsScreenState extends State<QuizOwnerResultsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _selectedQuiz = 'All Quizzes';

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
    }
    if (timestamp is DateTime) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
    }
    return timestamp.toString();
  }

  Future<Directory> _getPreferredDownloadDirectory() async {
    if (kIsWeb) {
      return getApplicationDocumentsDirectory();
    }

    final directories = await getExternalStorageDirectories(
      type: StorageDirectory.downloads,
    );
    if (directories != null && directories.isNotEmpty) {
      return directories.first;
    }

    return getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
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
          ? const Center(child: Text('Please log in to view quiz results.'))
          : StreamBuilder<QuerySnapshot>(
              // Removed server-side orderBy to avoid composite index errors.
              stream: _firestore
                  .collection('quiz_attempts')
                  .where('quizOwnerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allAttempts = snapshot.data!.docs
                    .map((d) => d.data() as Map<String, dynamic>)
                    .toList();

                if (allAttempts.isEmpty) {
                  return const Center(
                    child: Text('No join results yet. Share your quiz link.'),
                  );
                }

                // Sort locally by timestamp (newest first) if available
                allAttempts.sort((a, b) {
                  final ta = a['timestamp'];
                  final tb = b['timestamp'];
                  DateTime da = ta is Timestamp
                      ? ta.toDate()
                      : (ta is DateTime
                            ? ta
                            : DateTime.fromMillisecondsSinceEpoch(0));
                  DateTime db = tb is Timestamp
                      ? tb.toDate()
                      : (tb is DateTime
                            ? tb
                            : DateTime.fromMillisecondsSinceEpoch(0));
                  return db.compareTo(da);
                });

                final groupedByQuiz = <String, List<Map<String, dynamic>>>{};
                for (final attempt in allAttempts) {
                  final quizTitle = (attempt['quizTitle'] ?? 'Untitled Quiz')
                      .toString();
                  groupedByQuiz.putIfAbsent(quizTitle, () => []).add(attempt);
                }

                final quizNames = ['All Quizzes', ...groupedByQuiz.keys];
                if (!quizNames.contains(_selectedQuiz)) {
                  _selectedQuiz = 'All Quizzes';
                }

                final displayAttempts = _selectedQuiz == 'All Quizzes'
                    ? allAttempts
                    : groupedByQuiz[_selectedQuiz] ?? [];

                // AppBar action: export CSV
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12,
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: quizNames.map((name) {
                          final isSelected = name == _selectedQuiz;
                          return ChoiceChip(
                            label: Text(name),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedQuiz = name;
                              });
                            },
                            selectedColor: const Color(0xFF5C46BD),
                            backgroundColor: const Color(0xFFE8EAF6),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedQuiz == 'All Quizzes'
                                  ? 'Showing results for all quizzes'
                                  : 'Showing results for "$_selectedQuiz"',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4B4B4B),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: displayAttempts.isEmpty
                                ? null
                                : () async {
                                    final headers = [
                                      'Name',
                                      'Score',
                                      'Total',
                                      'Percentage',
                                      'TimeUsed',
                                      'Joined',
                                      'QuizTitle',
                                    ];
                                    final rows = displayAttempts.map((data) {
                                      final score = data['score'] ?? 0;
                                      final total = data['totalQuestions'] ?? 0;
                                      final percentage = total > 0
                                          ? ((score / total) * 100)
                                          : 0.0;
                                      final joined = _formatDate(
                                        data['timestamp'],
                                      );
                                      return [
                                        (data['studentName'] ?? 'Anonymous')
                                            .toString(),
                                        score.toString(),
                                        total.toString(),
                                        percentage.toStringAsFixed(1),
                                        (data['timeUsed'] ?? '').toString(),
                                        joined,
                                        (data['quizTitle'] ?? '').toString(),
                                      ];
                                    }).toList();

                                    final csvBuffer = StringBuffer();
                                    csvBuffer.writeln(headers.join(','));
                                    for (final r in rows) {
                                      final escaped = r
                                          .map((c) {
                                            final s = c.replaceAll('"', '""');
                                            if (s.contains(',') ||
                                                s.contains('\n') ||
                                                s.contains('"')) {
                                              return '"$s"';
                                            }
                                            return s;
                                          })
                                          .join(',');
                                      csvBuffer.writeln(escaped);
                                    }

                                    showModalBottomSheet(
                                      context: context,
                                      builder: (ctx) => SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Icons.file_download,
                                              ),
                                              title: const Text('Download CSV'),
                                              onTap: () async {
                                                Navigator.pop(ctx);
                                                if (kIsWeb) {
                                                  await Clipboard.setData(
                                                    ClipboardData(
                                                      text: csvBuffer
                                                          .toString(),
                                                    ),
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'CSV copied to clipboard (web).',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                try {
                                                  final directory =
                                                      await _getPreferredDownloadDirectory();
                                                  final safeName = _selectedQuiz
                                                      .replaceAll(
                                                        RegExp(r'[\\/:*?"<>|]'),
                                                        '_',
                                                      )
                                                      .replaceAll(' ', '_');
                                                  final file = File(
                                                    '${directory.path}/quiz_results_${safeName}.csv',
                                                  );
                                                  await file.writeAsString(
                                                    csvBuffer.toString(),
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Saved to ${file.path}',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 4,
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Download failed: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.share),
                                              title: const Text('Share CSV'),
                                              onTap: () async {
                                                Navigator.pop(ctx);
                                                if (kIsWeb) {
                                                  await Clipboard.setData(
                                                    ClipboardData(
                                                      text: csvBuffer
                                                          .toString(),
                                                    ),
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'CSV copied to clipboard (web).',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final tmpDir =
                                                    await getTemporaryDirectory();
                                                final safeName = _selectedQuiz
                                                    .replaceAll(
                                                      RegExp(r'[\\/:*?"<>|]'),
                                                      '_',
                                                    )
                                                    .replaceAll(' ', '_');
                                                final tmpFile = File(
                                                  '${tmpDir.path}/quiz_results_${safeName}.csv',
                                                );
                                                await tmpFile.writeAsString(
                                                  csvBuffer.toString(),
                                                );
                                                await Share.shareXFiles(
                                                  [XFile(tmpFile.path)],
                                                  text:
                                                      'Quiz results for $_selectedQuiz',
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Export CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2B9B),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: displayAttempts.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'No results found for "$_selectedQuiz".',
                                      style: const TextStyle(
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 800,
                                    ),
                                    child: DataTable(
                                      headingRowColor: MaterialStatePropertyAll(
                                        const Color(0xFF5C46BD),
                                      ),
                                      headingTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      dataRowColor:
                                          MaterialStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                              MaterialState.selected,
                                            )) {
                                              return const Color(0xFFE8EAF6);
                                            }
                                            return null;
                                          }),
                                      columns: const [
                                        DataColumn(label: Text('Name')),
                                        DataColumn(label: Text('Score')),
                                        DataColumn(label: Text('Total')),
                                        DataColumn(label: Text('Percentage')),
                                        DataColumn(label: Text('Time')),
                                        DataColumn(label: Text('Joined')),
                                        DataColumn(label: Text('Quiz')),
                                      ],
                                      rows: displayAttempts.map((data) {
                                        final score = data['score'] ?? 0;
                                        final total =
                                            data['totalQuestions'] ?? 0;
                                        final percentage = total > 0
                                            ? (score / total) * 100
                                            : 0.0;
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                data['studentName'] ??
                                                    'Anonymous',
                                              ),
                                            ),
                                            DataCell(Text(score.toString())),
                                            DataCell(Text(total.toString())),
                                            DataCell(
                                              Text(
                                                '${percentage.toStringAsFixed(1)}%',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                data['timeUsed']?.toString() ??
                                                    'N/A',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _formatDate(data['timestamp']),
                                              ),
                                            ),
                                            DataCell(
                                              Text(data['quizTitle'] ?? ''),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
