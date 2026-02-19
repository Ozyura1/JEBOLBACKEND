import 'package:flutter/material.dart';

/// Status badge for displaying submission/request status.
/// Government-appropriate color scheme.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    final normalized = status.toUpperCase();
    switch (normalized) {
      case 'PENDING':
      case 'MENUNGGU':
      case 'BARU':
        return _StatusConfig(
          label: 'Menunggu',
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade800,
        );
      case 'VERIFIED':
      case 'TERVERIFIKASI':
        return _StatusConfig(
          label: 'Terverifikasi',
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade800,
        );
      case 'APPROVED':
      case 'DISETUJUI':
        return _StatusConfig(
          label: 'Disetujui',
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade800,
        );
      case 'REJECTED':
      case 'DITOLAK':
        return _StatusConfig(
          label: 'Ditolak',
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade800,
        );
      case 'SCHEDULED':
      case 'TERJADWAL':
        return _StatusConfig(
          label: 'Terjadwal',
          backgroundColor: Colors.purple.shade50,
          borderColor: Colors.purple.shade200,
          textColor: Colors.purple.shade800,
        );
      case 'COMPLETED':
      case 'SELESAI':
        return _StatusConfig(
          label: 'Selesai',
          backgroundColor: Colors.teal.shade50,
          borderColor: Colors.teal.shade200,
          textColor: Colors.teal.shade800,
        );
      case 'REVISI':
      case 'REVISION':
        return _StatusConfig(
          label: 'Perlu Revisi',
          backgroundColor: Colors.amber.shade50,
          borderColor: Colors.amber.shade200,
          textColor: Colors.amber.shade800,
        );
      case 'CANCELLED':
      case 'DIBATALKAN':
        return _StatusConfig(
          label: 'Dibatalkan',
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          textColor: Colors.grey.shade700,
        );
      default:
        return _StatusConfig(
          label: status,
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          textColor: Colors.grey.shade700,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
