import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/schedule_provider.dart';

class RtScheduleScreen extends StatefulWidget {
  const RtScheduleScreen({super.key});

  @override
  State<RtScheduleScreen> createState() => _RtScheduleScreenState();
}

class _RtScheduleScreenState extends State<RtScheduleScreen> {
  late final ScheduleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ScheduleProvider();
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
      child: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Jadwal RT')),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildBody(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ScheduleProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.load(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (provider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Belum ada jadwal yang dijadwalkan.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.load(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView.separated(
        itemCount: provider.items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = provider.items[index];
          final typeLabel = item.submissionType.toUpperCase();
          return Card(
            elevation: 2,
            child: ListTile(
              leading: Chip(
                label: Text(
                  typeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: item.submissionType == 'ktp'
                    ? Colors.blue
                    : Colors.green,
              ),
              title: Text(
                item.title.isEmpty ? 'Jadwal' : item.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(item.date),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to detail screen or open modal with full details
              },
            ),
          );
        },
      ),
    );
  }
}
