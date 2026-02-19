import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/validators/marriage_validators.dart';
import '../provider/registration_provider.dart';
import '../model/marriage_request.dart';
import '../../../core/routing/route_paths.dart';
import 'package:go_router/go_router.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikPria = TextEditingController();
  final _nikWanita = TextEditingController();
  final _namaPria = TextEditingController();
  final _namaWanita = TextEditingController();
  final _alamat = TextEditingController();

  List<PlatformFile> _files = [];
  String? _fileError;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _files = result.files;
        _fileError = null;
      });
    }
  }

  Future<void> _submit(RegistrationProvider provider) async {
    if (provider.isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_files.isEmpty) {
      setState(() => _fileError = 'Dokumen wajib diunggah');
      return;
    }

    final request = MarriageRequest(
      nikPria: _nikPria.text.trim(),
      nikWanita: _nikWanita.text.trim(),
      namaPria: _namaPria.text.trim(),
      namaWanita: _namaWanita.text.trim(),
      alamat: _alamat.text.trim(),
    );

    final success = await provider.submit(request, _files);
    if (!mounted) return;
    if (success && provider.submittedUuid != null) {
      context.go(RoutePaths.publicMarriageStatus);
    }
  }

  @override
  void dispose() {
    _nikPria.dispose();
    _nikWanita.dispose();
    _namaPria.dispose();
    _namaWanita.dispose();
    _alamat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationProvider(),
      child: Consumer<RegistrationProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pendaftaran Perkawinan')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (provider.errorMessage != null) ...[
                      _ErrorBanner(message: provider.errorMessage!),
                      const SizedBox(height: 12),
                    ],
                    if (provider.successMessage != null) ...[
                      _SuccessBanner(message: provider.successMessage!),
                      const SizedBox(height: 12),
                    ],
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nikPria,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'NIK Pria',
                              border: OutlineInputBorder(),
                            ),
                            validator: MarriageValidators.nik,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _namaPria,
                            decoration: const InputDecoration(
                              labelText: 'Nama Pria',
                              border: OutlineInputBorder(),
                            ),
                            validator: MarriageValidators.nama,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nikWanita,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'NIK Wanita',
                              border: OutlineInputBorder(),
                            ),
                            validator: MarriageValidators.nik,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _namaWanita,
                            decoration: const InputDecoration(
                              labelText: 'Nama Wanita',
                              border: OutlineInputBorder(),
                            ),
                            validator: MarriageValidators.nama,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _alamat,
                            decoration: const InputDecoration(
                              labelText: 'Alamat',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: MarriageValidators.alamat,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _files.isEmpty
                                      ? 'Dokumen belum dipilih'
                                      : '${_files.length} file dipilih',
                                ),
                              ),
                              TextButton(
                                onPressed: provider.isSubmitting
                                    ? null
                                    : _pickFiles,
                                child: const Text('Pilih Dokumen'),
                              ),
                            ],
                          ),
                          if (_fileError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _fileError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Submit',
                            isLoading: provider.isSubmitting,
                            onPressed: () => _submit(provider),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String message;

  const _SuccessBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
