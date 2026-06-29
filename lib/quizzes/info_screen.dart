import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String body;

  const InfoScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C46BD),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF111E38),
            ),
          ),
        ),
      ),
    );
  }
}
