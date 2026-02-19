import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/validators/marriage_validators.dart';
import '../provider/status_provider.dart';

class MarriageStatusScreen extends StatefulWidget {
  const MarriageStatusScreen({super.key});

  @override
  State<MarriageStatusScreen> createState() => _MarriageStatusScreenState();
}

class _MarriageStatusScreenState extends State<MarriageStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuidController = TextEditingController();
  final _nikController = TextEditingController();

  @override
  void dispose() {
    _uuidController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarriageStatusProvider(),
      child: Consumer<MarriageStatusProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Status Perkawinan')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (provider.errorMessage != null) ...[
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _uuidController,
                          decoration: const InputDecoration(
                            labelText: 'UUID',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'UUID wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nikController,
                          decoration: const InputDecoration(
                            labelText: 'NIK',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: MarriageValidators.nik,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  provider.fetchStatus(
                                    _uuidController.text.trim(),
                                    _nikController.text.trim(),
                                  );
                                },
                          child: Text(
                            provider.isLoading ? 'Memuat...' : 'Cek Status',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (provider.statusData != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(provider.statusData.toString()),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
