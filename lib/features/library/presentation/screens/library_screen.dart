import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tủ Truyện'),
      ),
      body: const Center(
        child: Text(
          'Màn hình Tủ truyện',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
