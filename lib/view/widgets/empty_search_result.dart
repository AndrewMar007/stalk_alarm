import 'package:flutter/material.dart';

class EmptySearchResult extends StatelessWidget {
  const EmptySearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.search_off,
            size: 48,
            color: Color.fromARGB(140, 224, 125, 15),
          ),
          SizedBox(height: 12),
          Text(
            'Нічого не знайдено',
            style: TextStyle(
              color: Color.fromARGB(180, 248, 137, 41),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}