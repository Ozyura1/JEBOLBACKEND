import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/monitoring_provider.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  late final MonitoringProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MonitoringProvider();
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
      child: Consumer<MonitoringProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Monitoring & Audit')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildBody(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(MonitoringProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }
    if (provider.stats.isEmpty) {
      return const Center(child: Text('Belum ada data statistik.'));
    }
    return ListView.separated(
      itemCount: provider.stats.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final stat = provider.stats[index];
        return Card(
          child: ListTile(
            title: Text(stat.label.isEmpty ? 'Statistik' : stat.label),
            subtitle: Text(stat.value),
          ),
        );
      },
    );
  }
}
