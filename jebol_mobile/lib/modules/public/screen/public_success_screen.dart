import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../provider/public_locale_provider.dart';

/// Success screen after marriage registration submission.
/// Shows UUID for tracking. NO AUTH.
class PublicSuccessScreen extends StatelessWidget {
  final String uuid;
  final PublicLocaleProvider localeProvider;

  const PublicSuccessScreen({
    super.key,
    required this.uuid,
    required this.localeProvider,
  });

  String _tr(String key) => localeProvider.tr(key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green.shade600,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _tr('success_title'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                _tr('success_message'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // UUID Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _tr('success_registration_number'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      uuid,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(_tr('success_copy')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1565C0),
                        side: const BorderSide(color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Next steps
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.checklist,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _tr('success_next_steps'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStep(1, _tr('success_step_1')),
                    _buildStep(2, _tr('success_step_2')),
                    _buildStep(3, _tr('success_step_3')),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/public/marriage/track',
                      arguments: {'uuid': uuid, 'locale': localeProvider},
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: Text(_tr('success_check_status')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/public',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: Text(_tr('success_back_home')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF1565C0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Footer
              Text(
                '© 2025 Dinas Kependudukan dan Pencatatan Sipil',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: uuid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_tr('success_copied')),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
