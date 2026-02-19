import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/gps_picker.dart';
import '../../../shared/validators/rt_validators.dart';
import '../provider/ikd_provider.dart';
import '../model/ikd_request.dart';

class IkdFormScreen extends StatefulWidget {
  const IkdFormScreen({super.key});

  @override
  State<IkdFormScreen> createState() => _IkdFormScreenState();
}

class _IkdFormScreenState extends State<IkdFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nomorTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');

  LocationData? _location;
  String? _locationError;

  Future<void> _submit(IkdProvider provider) async {
    if (provider.isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_location?.latitude == null || _location?.longitude == null) {
      setState(() => _locationError = 'Lokasi GPS wajib diambil');
      return;
    }

    final request = IkdRequest(
      nama: _namaController.text.trim(),
      nomorTelp: _nomorTelpController.text.trim(),
      alamatManual: _alamatController.text.trim(),
      latitude: _location!.latitude!,
      longitude: _location!.longitude!,
      jumlahPemohon: int.parse(_jumlahController.text.trim()),
    );

    await provider.submit(request);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorTelpController.dispose();
    _alamatController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IkdProvider(),
      child: Consumer<IkdProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Form IKD (RT)')),
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
                            controller: _namaController,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              border: OutlineInputBorder(),
                            ),
                            validator: RtValidators.nama,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nomorTelpController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Nomor Telepon',
                              border: OutlineInputBorder(),
                            ),
                            validator: RtValidators.nomorTelp,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _alamatController,
                            decoration: const InputDecoration(
                              labelText: 'Alamat Manual',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: RtValidators.alamat,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _jumlahController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Pemohon',
                              border: OutlineInputBorder(),
                            ),
                            validator: RtValidators.jumlahPemohon(1),
                          ),
                          const SizedBox(height: 16),
                          GpsPicker(
                            onLocationPicked: (loc) {
                              setState(() {
                                _location = loc;
                                _locationError = null;
                              });
                            },
                            initial: _location,
                          ),
                          if (_locationError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _locationError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Submit IKD',
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

// Banner Widgets
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return _BannerBase(
      icon: Icons.error_outline,
      color: Colors.red,
      message: message,
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String message;
  const _SuccessBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return _BannerBase(
      icon: Icons.check_circle_outline,
      color: Colors.green,
      message: message,
    );
  }
}

// Base Banner
class _BannerBase extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _BannerBase({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
