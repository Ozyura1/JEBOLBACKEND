import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/gps_picker.dart';
import '../../../shared/validators/rt_validators.dart';
import '../provider/ktp_provider.dart';
import '../model/ktp_request.dart';
import '../model/ktp_category.dart';

class KtpFormScreen extends StatefulWidget {
  const KtpFormScreen({super.key});

  @override
  State<KtpFormScreen> createState() => _KtpFormScreenState();
}

class _KtpFormScreenState extends State<KtpFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nomorTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');

  KtpCategory? _selectedCategory;
  KhususCategory? _selectedKhususCategory;
  LocationData? _location;
  String? _locationError;

  int _getMinimalJumlah() {
    if (_selectedCategory == null) return 1;
    return _selectedCategory!.minimalJumlah;
  }

  int _getMinimalUsia() {
    if (_selectedCategory == KtpCategory.khusus) {
      if (_selectedKhususCategory == KhususCategory.lansia) return 60;
      if (_selectedKhususCategory == KhususCategory.odgj) return 17;
    }
    return _selectedCategory?.minimalUsia ?? 16;
  }

  Future<void> _submit(KtpProvider provider) async {
    if (provider.isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori KTP terlebih dahulu')),
      );
      return;
    }
    if (_selectedCategory == KtpCategory.khusus && _selectedKhususCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis khusus (Lansia/ODGJ)')),
      );
      return;
    }
    if (_location?.latitude == null || _location?.longitude == null) {
      setState(() => _locationError = 'Lokasi GPS wajib diambil');
      return;
    }

    final request = KtpRequest(
      kategori: _selectedCategory!,
      kategoriKhusus: _selectedKhususCategory,
      minimalUsia: _getMinimalUsia(),
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
      create: (_) => KtpProvider(),
      child: Consumer<KtpProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Form KTP (RT)')),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Selection
                          const Text(
                            'Pilih Kategori KTP',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCategorySelection(),
                          const SizedBox(height: 24),

                          // Khusus Category Selection
                          if (_selectedCategory == KtpCategory.khusus) ...[
                            const Text(
                              'Pilih Jenis Khusus',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildKhususCategorySelection(),
                            const SizedBox(height: 24),
                          ],

                          // Form Fields
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
                            decoration: InputDecoration(
                              labelText: 'Jumlah Pemohon',
                              helperText: 'Minimal ${_getMinimalJumlah()} orang',
                              border: const OutlineInputBorder(),
                            ),
                            validator: RtValidators.jumlahPemohon(_getMinimalJumlah()),
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
                            label: 'Submit KTP',
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

  Widget _buildCategorySelection() {
    return Column(
      children: [
        _buildCategoryCard(
          category: KtpCategory.umum,
          title: KtpCategory.umum.label,
          subtitle: 'Minimum 15 orang, usia 16+ tahun',
        ),
        const SizedBox(height: 12),
        _buildCategoryCard(
          category: KtpCategory.khusus,
          title: KtpCategory.khusus.label,
          subtitle: 'Khusus Lansia (60+) atau ODGJ (17+)',
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required KtpCategory category,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedCategory == category;
    return Card(
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Radio<KtpCategory>(
          value: category,
          groupValue: _selectedCategory,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              _selectedKhususCategory = null;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedCategory = category;
            _selectedKhususCategory = null;
          });
        },
      ),
    );
  }

  Widget _buildKhususCategorySelection() {
    return Column(
      children: [
        _buildKhususCard(
          category: KhususCategory.lansia,
          title: KhususCategory.lansia.label,
        ),
        const SizedBox(height: 12),
        _buildKhususCard(
          category: KhususCategory.odgj,
          title: KhususCategory.odgj.label,
        ),
      ],
    );
  }

  Widget _buildKhususCard({
    required KhususCategory category,
    required String title,
  }) {
    final isSelected = _selectedKhususCategory == category;
    return Card(
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Radio<KhususCategory>(
          value: category,
          groupValue: _selectedKhususCategory,
          onChanged: (value) {
            setState(() => _selectedKhususCategory = value);
          },
        ),
        onTap: () {
          setState(() => _selectedKhususCategory = category);
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
