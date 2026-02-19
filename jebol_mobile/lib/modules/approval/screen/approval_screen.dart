import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/approval_provider.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  late final ApprovalProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ApprovalProvider();
    _provider.load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ApprovalProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Approval & Jadwal')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildBody(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ApprovalProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }
    if (provider.items.isEmpty) {
      return const Center(child: Text('Belum ada pengajuan.'));
    }
    return ListView.separated(
      itemCount: provider.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return Card(
          child: ListTile(
            title: Text(item.title.isEmpty ? 'Pengajuan' : item.title),
            subtitle: Text('Status: ${item.status}'),
            trailing: const Icon(Icons.lock_outline),
            onTap: null,
          ),
        );
      },
    );
  }
}
