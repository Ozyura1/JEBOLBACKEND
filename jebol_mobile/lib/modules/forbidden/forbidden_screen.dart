import 'package:flutter/material.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akses Ditolak')),
      body: const Center(
        child: Text(
          'Anda tidak memiliki izin untuk mengakses halaman ini.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
