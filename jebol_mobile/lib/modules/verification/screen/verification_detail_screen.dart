import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/verification_provider.dart';

class VerificationDetailScreen extends StatefulWidget {
  final String id;

  const VerificationDetailScreen({super.key, required this.id});

  @override
  State<VerificationDetailScreen> createState() =>
      _VerificationDetailScreenState();
}

class _VerificationDetailScreenState extends State<VerificationDetailScreen> {
  late final VerificationProvider _provider;
  final _revisiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = VerificationProvider();
    _provider.loadDetail(widget.id);
  }

  @override
  void dispose() {
    _provider.dispose();
    _revisiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<VerificationProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Verifikasi')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildBody(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(VerificationProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    final detail = provider.detail;
    if (detail == null) {
      return const Center(child: Text('Detail tidak tersedia.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('ID: ${widget.id}'),
        const SizedBox(height: 8),
        Text('Data: ${detail.toString()}'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            await provider.markValid(widget.id);
          },
          child: const Text('Tandai Valid'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _revisiController,
          decoration: const InputDecoration(
            labelText: 'Catatan Revisi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            await provider.markRevisi(widget.id, _revisiController.text.trim());
          },
          child: const Text('Minta Revisi'),
        ),
      ],
    );
  }
}
