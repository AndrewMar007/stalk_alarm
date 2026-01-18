import 'package:flutter/material.dart';

class OblastDetailsPage extends StatelessWidget {
  final int id;
  final String title;

  const OblastDetailsPage({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(23, 13, 2, 1),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: const Color.fromARGB(255, 247, 135, 50),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'ID: $id\nuid: oblast_$id',
          style: const TextStyle(
            color: Color.fromARGB(255, 206, 113, 42),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
