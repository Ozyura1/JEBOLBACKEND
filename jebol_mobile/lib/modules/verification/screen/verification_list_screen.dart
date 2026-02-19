import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/verification_provider.dart';
import '../../../core/routing/route_paths.dart';

class VerificationListScreen extends StatefulWidget {
  const VerificationListScreen({super.key});

  @override
  State<VerificationListScreen> createState() => _VerificationListScreenState();
}

class _VerificationListScreenState extends State<VerificationListScreen> {
  late final VerificationProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = VerificationProvider();
    _provider.loadList();
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
      child: Consumer<VerificationProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Verifikasi Berkas')),
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
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go(
                RoutePaths.rtVerificationDetail.replaceFirst(':id', item.id),
              );
            },
          ),
        );
      },
    );
  }
}
