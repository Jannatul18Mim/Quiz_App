import 'package:flutter/material.dart';

// Deep mock schema architectures to track offline content updates
class AdminQuiz {
  String id;
  String title;
  AdminQuiz({required this.id, required this.title});
}

class AdminSubject {
  String id;
  String title;
  List<AdminQuiz> quizzes;
  AdminSubject({required this.id, required this.title, required this.quizzes});
}

class AdminClass {
  String id;
  String className;
  List<AdminSubject> subjects;
  AdminClass({
    required this.id,
    required this.className,
    required this.subjects,
  });
}

class AdminClassesManager extends StatefulWidget {
  const AdminClassesManager({super.key});

  @override
  State<AdminClassesManager> createState() => _AdminClassesManagerState();
}

class _AdminClassesManagerState extends State<AdminClassesManager> {
  // Pre-seeded offline framework states
  final List<AdminClass> _classesData = [
    AdminClass(
      id: '1',
      className: 'Class 9',
      subjects: [
        AdminSubject(
          id: 's1',
          title: 'Mathematics',
          quizzes: [AdminQuiz(id: 'q1', title: 'Equations Base Check')],
        ),
        AdminSubject(id: 's2', title: 'Physics', quizzes: []),
      ],
    ),
    AdminClass(id: '2', className: 'Class 10', subjects: []),
  ];

  // Helper handling programmatic alert text-entries
  void _showFormDialog({
    required String dialogTitle,
    String existingValue = '',
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: existingValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter name/title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Structure Manager'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            tooltip: 'Add Class',
            onPressed: () => _showFormDialog(
              dialogTitle: 'Create Offline Class Node',
              onSave: (val) {
                setState(() {
                  _classesData.add(
                    AdminClass(
                      id: DateTime.now().toString(),
                      className: val,
                      subjects: [],
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
      body: _classesData.isEmpty
          ? const Center(child: Text('No classes setup yet.'))
          : ListView.builder(
              itemCount: _classesData.length,
              itemBuilder: (context, cIndex) {
                final classNode = _classesData[cIndex];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      classNode.className,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    leading: const Icon(Icons.gite, color: Colors.blueGrey),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.green,
                          ),
                          onPressed: () => _showFormDialog(
                            dialogTitle:
                                'Add Subject to ${classNode.className}',
                            onSave: (subName) {
                              setState(() {
                                classNode.subjects.add(
                                  AdminSubject(
                                    id: DateTime.now().toString(),
                                    title: subName,
                                    quizzes: [],
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showFormDialog(
                            dialogTitle: 'Rename Class',
                            existingValue: classNode.className,
                            onSave: (newName) {
                              setState(() {
                                classNode.className = newName;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _classesData.removeAt(cIndex);
                            });
                          },
                        ),
                      ],
                    ),
                    children: classNode.subjects.map((subNode) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: ExpansionTile(
                          title: Text(
                            subNode.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.playlist_add,
                                  color: Colors.teal,
                                ),
                                onPressed: () => _showFormDialog(
                                  dialogTitle: 'Add Quiz to ${subNode.title}',
                                  onSave: (qTitle) {
                                    setState(() {
                                      subNode.quizzes.add(
                                        AdminQuiz(
                                          id: DateTime.now().toString(),
                                          title: qTitle,
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    classNode.subjects.remove(subNode);
                                  });
                                },
                              ),
                            ],
                          ),
                          children: subNode.quizzes.map((quizNode) {
                            return ListTile(
                              leading: const Icon(
                                Icons.quiz,
                                color: Colors.purple,
                              ),
                              title: Text(quizNode.title),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_note,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () => _showFormDialog(
                                      dialogTitle: 'Edit Quiz Title',
                                      existingValue: quizNode.title,
                                      onSave: (updatedText) {
                                        setState(() {
                                          quizNode.title = updatedText;
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        subNode.quizzes.remove(quizNode);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
