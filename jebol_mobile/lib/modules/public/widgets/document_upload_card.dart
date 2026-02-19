import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../provider/public_locale_provider.dart';

/// Document upload card with preview.
class DocumentUploadCard extends StatelessWidget {
  final String label;
  final String description;
  final File? file;
  final void Function(File?) onFileSelected;
  final String? errorText;
  final PublicLocaleProvider localeProvider;
  final bool required;

  const DocumentUploadCard({
    super.key,
    required this.label,
    required this.description,
    required this.file,
    required this.onFileSelected,
    required this.localeProvider,
    this.errorText,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    final hasError = errorText != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? Colors.red
              : hasFile
              ? Colors.green.shade300
              : Colors.grey.shade300,
          width: hasError || hasFile ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasFile
                        ? Colors.green.shade50
                        : const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle : Icons.insert_drive_file,
                    color: hasFile ? Colors.green : const Color(0xFF1565C0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                          if (required)
                            const Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // File preview or upload button
          if (hasFile) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Preview
                  if (_isImage(file!.path))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        file!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFileName(file!.path),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getFileSize(file!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  IconButton(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(Icons.edit, size: 20),
                    color: const Color(0xFF1565C0),
                    tooltip: 'Ganti',
                  ),
                  IconButton(
                    onPressed: () => onFileSelected(null),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red,
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ),
          ] else ...[
            // Upload button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickFile(context),
                  icon: const Icon(Icons.upload_file),
                  label: Text(localeProvider.tr('doc_upload')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF1565C0)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],

          // Error text
          if (hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                errorText!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          final file = File(path);

          // Check file size (max 2MB)
          final size = await file.length();
          if (size > 2 * 1024 * 1024) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localeProvider.tr('validation_file_too_large')),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          onFileSelected(file);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memilih file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isImage(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(ext);
  }

  String _getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }
}
