import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/public_locale_provider.dart';
import '../model/public_marriage_form.dart';
import '../service/public_api_service.dart';
import '../widgets/public_app_bar.dart';
import '../widgets/dukcapil_text_field.dart';
import '../widgets/document_upload_card.dart';

/// Multi-step marriage registration form.
/// Completely isolated from admin flow. NO AUTH.
class PublicMarriageFormScreen extends StatefulWidget {
  final PublicLocaleProvider? initialLocale;

  const PublicMarriageFormScreen({super.key, this.initialLocale});

  @override
  State<PublicMarriageFormScreen> createState() =>
      _PublicMarriageFormScreenState();
}

class _PublicMarriageFormScreenState extends State<PublicMarriageFormScreen> {
  late PublicLocaleProvider _localeProvider;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
  final _form = PublicMarriageForm();

  int _currentStep = 0;
  bool _isSubmitting = false;
  Map<String, String>? _serverErrors;

  // Controllers - Pria
  final _nikPriaController = TextEditingController();
  final _namaPriaController = TextEditingController();
  final _tempatLahirPriaController = TextEditingController();
  final _alamatPriaController = TextEditingController();
  final _rtPriaController = TextEditingController();
  final _rwPriaController = TextEditingController();
  final _kelurahanPriaController = TextEditingController();
  final _kecamatanPriaController = TextEditingController();
  final _pekerjaanPriaController = TextEditingController();
  final _phonePriaController = TextEditingController();

  // Controllers - Wanita
  final _nikWanitaController = TextEditingController();
  final _namaWanitaController = TextEditingController();
  final _tempatLahirWanitaController = TextEditingController();
  final _alamatWanitaController = TextEditingController();
  final _rtWanitaController = TextEditingController();
  final _rwWanitaController = TextEditingController();
  final _kelurahanWanitaController = TextEditingController();
  final _kecamatanWanitaController = TextEditingController();
  final _pekerjaanWanitaController = TextEditingController();
  final _phoneWanitaController = TextEditingController();

  // Controllers - Marriage
  final _tempatNikahController = TextEditingController();
  final _namaWaliController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localeProvider = widget.initialLocale ?? PublicLocaleProvider();
  }

  @override
  void dispose() {
    _nikPriaController.dispose();
    _namaPriaController.dispose();
    _tempatLahirPriaController.dispose();
    _alamatPriaController.dispose();
    _rtPriaController.dispose();
    _rwPriaController.dispose();
    _kelurahanPriaController.dispose();
    _kecamatanPriaController.dispose();
    _pekerjaanPriaController.dispose();
    _phonePriaController.dispose();
    _nikWanitaController.dispose();
    _namaWanitaController.dispose();
    _tempatLahirWanitaController.dispose();
    _alamatWanitaController.dispose();
    _rtWanitaController.dispose();
    _rwWanitaController.dispose();
    _kelurahanWanitaController.dispose();
    _kecamatanWanitaController.dispose();
    _pekerjaanWanitaController.dispose();
    _phoneWanitaController.dispose();
    _tempatNikahController.dispose();
    _namaWaliController.dispose();
    super.dispose();
  }

  String _tr(String key) => _localeProvider.tr(key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _localeProvider,
      child: Consumer<PublicLocaleProvider>(
        builder: (context, locale, _) {
          return Scaffold(
            appBar: PublicAppBar(
              title: _tr('form_title'),
              localeProvider: locale,
            ),
            body: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),

                // Form content
                Expanded(child: _buildCurrentStep()),

                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF1565C0)
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                      ),
                    ),
                    if (index < 4)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < _currentStep
                              ? const Color(0xFF1565C0)
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${_tr('form_step')} ${_currentStep + 1} ${_tr('form_of')} 5: ${_getStepTitle(_currentStep)}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return _tr('step1_title');
      case 1:
        return _tr('step2_title');
      case 2:
        return _tr('step3_title');
      case 3:
        return _tr('step4_title');
      case 4:
        return _tr('step5_title');
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[_currentStep],
        child: _buildStepContent(_currentStep),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildStep1Pria();
      case 1:
        return _buildStep2Wanita();
      case 2:
        return _buildStep3Marriage();
      case 3:
        return _buildStep4Documents();
      case 4:
        return _buildStep5Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Pria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NikTextField(
          controller: _nikPriaController,
          label: _tr('field_nik'),
          validator: (v) => DukcapilValidator.validateNik(v, _tr),
        ),
        const SizedBox(height: 16),
        NameTextField(
          controller: _namaPriaController,
          label: _tr('field_nama_lengkap'),
          validator: (v) => DukcapilValidator.validateName(v, _tr),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _tempatLahirPriaController,
          label: _tr('field_tempat_lahir'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        DatePickerField(
          label: _tr('field_tanggal_lahir'),
          value: _form.tanggalLahirPria,
          required: true,
          lastDate: DateTime.now(),
          firstDate: DateTime(1900),
          validator: (v) =>
              DukcapilValidator.validateBirthDate(v, _tr, isMale: true),
          onChanged: (date) => setState(() => _form.tanggalLahirPria = date),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _alamatPriaController,
          label: _tr('field_alamat'),
          required: true,
          maxLines: 2,
          validator: (v) => DukcapilValidator.validateAddress(v, _tr),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: RtRwTextField(
                controller: _rtPriaController,
                label: _tr('field_rt'),
                validator: (v) => DukcapilValidator.validateRtRw(v, _tr),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RtRwTextField(
                controller: _rwPriaController,
                label: _tr('field_rw'),
                validator: (v) => DukcapilValidator.validateRtRw(v, _tr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _kelurahanPriaController,
          label: _tr('field_kelurahan'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _kecamatanPriaController,
          label: _tr('field_kecamatan'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        DukcapilDropdown<String>(
          label: _tr('field_agama'),
          value: _form.agamaPria.isEmpty ? null : _form.agamaPria,
          required: true,
          items: FormOptions.agamaKeys
              .map(
                (key) => DropdownMenuItem(
                  value: FormOptions.agamaValues[key],
                  child: Text(_tr(key)),
                ),
              )
              .toList(),
          validator: (v) => v == null ? _tr('validation_required') : null,
          onChanged: (v) => setState(() => _form.agamaPria = v ?? ''),
        ),
        const SizedBox(height: 16),
        DukcapilDropdown<String>(
          label: _tr('field_status_kawin'),
          value: _form.statusKawinPria.isEmpty ? null : _form.statusKawinPria,
          required: true,
          items: FormOptions.statusKawinKeys
              .map(
                (key) => DropdownMenuItem(
                  value: FormOptions.statusKawinValues[key],
                  child: Text(_tr(key)),
                ),
              )
              .toList(),
          validator: (v) => v == null ? _tr('validation_required') : null,
          onChanged: (v) => setState(() => _form.statusKawinPria = v ?? ''),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _pekerjaanPriaController,
          label: _tr('field_pekerjaan'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        PhoneTextField(
          controller: _phonePriaController,
          label: _tr('field_no_hp'),
          validator: (v) => DukcapilValidator.validatePhone(v, _tr),
        ),
      ],
    );
  }

  Widget _buildStep2Wanita() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NikTextField(
          controller: _nikWanitaController,
          label: _tr('field_nik'),
          validator: (v) => DukcapilValidator.validateNik(v, _tr),
        ),
        const SizedBox(height: 16),
        NameTextField(
          controller: _namaWanitaController,
          label: _tr('field_nama_lengkap'),
          validator: (v) => DukcapilValidator.validateName(v, _tr),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _tempatLahirWanitaController,
          label: _tr('field_tempat_lahir'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        DatePickerField(
          label: _tr('field_tanggal_lahir'),
          value: _form.tanggalLahirWanita,
          required: true,
          lastDate: DateTime.now(),
          firstDate: DateTime(1900),
          validator: (v) =>
              DukcapilValidator.validateBirthDate(v, _tr, isMale: false),
          onChanged: (date) => setState(() => _form.tanggalLahirWanita = date),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _alamatWanitaController,
          label: _tr('field_alamat'),
          required: true,
          maxLines: 2,
          validator: (v) => DukcapilValidator.validateAddress(v, _tr),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: RtRwTextField(
                controller: _rtWanitaController,
                label: _tr('field_rt'),
                validator: (v) => DukcapilValidator.validateRtRw(v, _tr),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RtRwTextField(
                controller: _rwWanitaController,
                label: _tr('field_rw'),
                validator: (v) => DukcapilValidator.validateRtRw(v, _tr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _kelurahanWanitaController,
          label: _tr('field_kelurahan'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _kecamatanWanitaController,
          label: _tr('field_kecamatan'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        DukcapilDropdown<String>(
          label: _tr('field_agama'),
          value: _form.agamaWanita.isEmpty ? null : _form.agamaWanita,
          required: true,
          items: FormOptions.agamaKeys
              .map(
                (key) => DropdownMenuItem(
                  value: FormOptions.agamaValues[key],
                  child: Text(_tr(key)),
                ),
              )
              .toList(),
          validator: (v) => v == null ? _tr('validation_required') : null,
          onChanged: (v) => setState(() => _form.agamaWanita = v ?? ''),
        ),
        const SizedBox(height: 16),
        DukcapilDropdown<String>(
          label: _tr('field_status_kawin'),
          value: _form.statusKawinWanita.isEmpty
              ? null
              : _form.statusKawinWanita,
          required: true,
          items: FormOptions.statusKawinKeys
              .map(
                (key) => DropdownMenuItem(
                  value: FormOptions.statusKawinValues[key],
                  child: Text(_tr(key)),
                ),
              )
              .toList(),
          validator: (v) => v == null ? _tr('validation_required') : null,
          onChanged: (v) => setState(() => _form.statusKawinWanita = v ?? ''),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _pekerjaanWanitaController,
          label: _tr('field_pekerjaan'),
          required: true,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        PhoneTextField(
          controller: _phoneWanitaController,
          label: _tr('field_no_hp'),
          validator: (v) => DukcapilValidator.validatePhone(v, _tr),
        ),
      ],
    );
  }

  Widget _buildStep3Marriage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DatePickerField(
          label: _tr('field_tanggal_nikah_rencana'),
          value: _form.tanggalNikahRencana,
          required: true,
          firstDate: DateTime.now().add(const Duration(days: 14)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          validator: (v) => DukcapilValidator.validateMarriageDate(v, _tr),
          onChanged: (date) => setState(() => _form.tanggalNikahRencana = date),
        ),
        const SizedBox(height: 16),
        DukcapilTextField(
          controller: _tempatNikahController,
          label: _tr('field_tempat_nikah'),
          required: true,
          maxLines: 2,
          validator: (v) => DukcapilValidator.validateRequired(v, _tr),
        ),
        const SizedBox(height: 16),
        NameTextField(
          controller: _namaWaliController,
          label: _tr('field_nama_wali'),
          validator: (v) => DukcapilValidator.validateName(v, _tr),
        ),
        const SizedBox(height: 16),
        DukcapilDropdown<String>(
          label: _tr('field_hubungan_wali'),
          value: _form.hubunganWali.isEmpty ? null : _form.hubunganWali,
          required: true,
          items: FormOptions.hubunganWaliKeys
              .map(
                (key) => DropdownMenuItem(
                  value: FormOptions.hubunganWaliValues[key],
                  child: Text(_tr(key)),
                ),
              )
              .toList(),
          validator: (v) => v == null ? _tr('validation_required') : null,
          onChanged: (v) => setState(() => _form.hubunganWali = v ?? ''),
        ),
      ],
    );
  }

  Widget _buildStep4Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tr('doc_max_size'),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        DocumentUploadCard(
          label: _tr('doc_ktp_pria'),
          description: 'JPG/PNG/PDF',
          file: _form.ktpPria,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['ktp_pria'],
          onFileSelected: (f) => setState(() => _form.ktpPria = f),
        ),
        DocumentUploadCard(
          label: _tr('doc_ktp_wanita'),
          description: 'JPG/PNG/PDF',
          file: _form.ktpWanita,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['ktp_wanita'],
          onFileSelected: (f) => setState(() => _form.ktpWanita = f),
        ),
        DocumentUploadCard(
          label: _tr('doc_kk_pria'),
          description: 'JPG/PNG/PDF',
          file: _form.kkPria,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['kk_pria'],
          onFileSelected: (f) => setState(() => _form.kkPria = f),
        ),
        DocumentUploadCard(
          label: _tr('doc_kk_wanita'),
          description: 'JPG/PNG/PDF',
          file: _form.kkWanita,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['kk_wanita'],
          onFileSelected: (f) => setState(() => _form.kkWanita = f),
        ),
        DocumentUploadCard(
          label: _tr('doc_akta_lahir_pria'),
          description: 'JPG/PNG/PDF',
          file: _form.aktaLahirPria,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['akta_lahir_pria'],
          onFileSelected: (f) => setState(() => _form.aktaLahirPria = f),
        ),
        DocumentUploadCard(
          label: _tr('doc_akta_lahir_wanita'),
          description: 'JPG/PNG/PDF',
          file: _form.aktaLahirWanita,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['akta_lahir_wanita'],
          onFileSelected: (f) => setState(() => _form.aktaLahirWanita = f),
        ),
        DocumentUploadCard(
          label: _tr('doc_surat_pengantar'),
          description: 'JPG/PNG/PDF',
          file: _form.suratPengantar,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['surat_pengantar'],
          onFileSelected: (f) => setState(() => _form.suratPengantar = f),
        ),
        DocumentUploadCard(
          label: _tr('doc_foto_bersama'),
          description: 'JPG/PNG',
          file: _form.fotoBersama,
          localeProvider: _localeProvider,
          errorText: _serverErrors?['foto_bersama'],
          onFileSelected: (f) => setState(() => _form.fotoBersama = f),
        ),
      ],
    );
  }

  Widget _buildStep5Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewSection(
          title: _tr('step1_title'),
          items: {
            _tr('field_nik'): _nikPriaController.text,
            _tr('field_nama_lengkap'): _namaPriaController.text,
            _tr('field_tempat_lahir'): _tempatLahirPriaController.text,
            _tr('field_tanggal_lahir'): _formatDate(_form.tanggalLahirPria),
            _tr('field_alamat'): _alamatPriaController.text,
            'RT/RW': '${_rtPriaController.text}/${_rwPriaController.text}',
            _tr('field_kelurahan'): _kelurahanPriaController.text,
            _tr('field_kecamatan'): _kecamatanPriaController.text,
            _tr('field_agama'): _form.agamaPria,
            _tr('field_status_kawin'): _form.statusKawinPria,
            _tr('field_pekerjaan'): _pekerjaanPriaController.text,
            _tr('field_no_hp'): _phonePriaController.text,
          },
          onEdit: () => setState(() => _currentStep = 0),
        ),
        const SizedBox(height: 16),
        _buildReviewSection(
          title: _tr('step2_title'),
          items: {
            _tr('field_nik'): _nikWanitaController.text,
            _tr('field_nama_lengkap'): _namaWanitaController.text,
            _tr('field_tempat_lahir'): _tempatLahirWanitaController.text,
            _tr('field_tanggal_lahir'): _formatDate(_form.tanggalLahirWanita),
            _tr('field_alamat'): _alamatWanitaController.text,
            'RT/RW': '${_rtWanitaController.text}/${_rwWanitaController.text}',
            _tr('field_kelurahan'): _kelurahanWanitaController.text,
            _tr('field_kecamatan'): _kecamatanWanitaController.text,
            _tr('field_agama'): _form.agamaWanita,
            _tr('field_status_kawin'): _form.statusKawinWanita,
            _tr('field_pekerjaan'): _pekerjaanWanitaController.text,
            _tr('field_no_hp'): _phoneWanitaController.text,
          },
          onEdit: () => setState(() => _currentStep = 1),
        ),
        const SizedBox(height: 16),
        _buildReviewSection(
          title: _tr('step3_title'),
          items: {
            _tr('field_tanggal_nikah_rencana'): _formatDate(
              _form.tanggalNikahRencana,
            ),
            _tr('field_tempat_nikah'): _tempatNikahController.text,
            _tr('field_nama_wali'): _namaWaliController.text,
            _tr('field_hubungan_wali'): _form.hubunganWali,
          },
          onEdit: () => setState(() => _currentStep = 2),
        ),
        const SizedBox(height: 16),
        _buildDocumentReview(),
        const SizedBox(height: 24),
        // Confirmation checkbox
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _form.confirmed,
                onChanged: (v) => setState(() => _form.confirmed = v ?? false),
                activeColor: const Color(0xFF1565C0),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _tr('review_confirm'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection({
    required String title,
    required Map<String, String> items,
    required VoidCallback onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(_tr('review_edit')),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: items.entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const Text(': '),
                          Expanded(
                            child: Text(
                              e.value.isEmpty ? '-' : e.value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentReview() {
    final docs = [
      (_tr('doc_ktp_pria'), _form.ktpPria),
      (_tr('doc_ktp_wanita'), _form.ktpWanita),
      (_tr('doc_kk_pria'), _form.kkPria),
      (_tr('doc_kk_wanita'), _form.kkWanita),
      (_tr('doc_akta_lahir_pria'), _form.aktaLahirPria),
      (_tr('doc_akta_lahir_wanita'), _form.aktaLahirWanita),
      (_tr('doc_surat_pengantar'), _form.suratPengantar),
      (_tr('doc_foto_bersama'), _form.fotoBersama),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tr('step4_title'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _currentStep = 3),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(_tr('review_edit')),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: docs.map((doc) {
                final hasFile = doc.$2 != null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        hasFile ? Icons.check_circle : Icons.error_outline,
                        size: 18,
                        color: hasFile ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          doc.$1,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        hasFile ? _tr('doc_uploaded') : '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasFile ? Colors.green : Colors.grey,
                          fontWeight: hasFile
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF1565C0)),
                ),
                child: Text(_tr('form_previous')),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 4 ? _tr('form_submit') : _tr('form_next'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleNext() {
    // Validate current step
    if (_currentStep < 4) {
      if (_formKeys[_currentStep].currentState?.validate() ?? false) {
        _saveCurrentStepData();
        setState(() => _currentStep++);
      }
    } else {
      // Submit
      if (!_form.confirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localeProvider.isIndonesian
                  ? 'Harap centang pernyataan konfirmasi'
                  : 'Please check the confirmation statement',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      _validateDocumentsAndSubmit();
    }
  }

  void _saveCurrentStepData() {
    switch (_currentStep) {
      case 0:
        _form.nikPria = _nikPriaController.text;
        _form.namaLengkapPria = _namaPriaController.text;
        _form.tempatLahirPria = _tempatLahirPriaController.text;
        _form.alamatPria = _alamatPriaController.text;
        _form.rtPria = _rtPriaController.text;
        _form.rwPria = _rwPriaController.text;
        _form.kelurahanPria = _kelurahanPriaController.text;
        _form.kecamatanPria = _kecamatanPriaController.text;
        _form.pekerjaanPria = _pekerjaanPriaController.text;
        _form.noHpPria = _phonePriaController.text;
        break;
      case 1:
        _form.nikWanita = _nikWanitaController.text;
        _form.namaLengkapWanita = _namaWanitaController.text;
        _form.tempatLahirWanita = _tempatLahirWanitaController.text;
        _form.alamatWanita = _alamatWanitaController.text;
        _form.rtWanita = _rtWanitaController.text;
        _form.rwWanita = _rwWanitaController.text;
        _form.kelurahanWanita = _kelurahanWanitaController.text;
        _form.kecamatanWanita = _kecamatanWanitaController.text;
        _form.pekerjaanWanita = _pekerjaanWanitaController.text;
        _form.noHpWanita = _phoneWanitaController.text;
        break;
      case 2:
        _form.tempatNikah = _tempatNikahController.text;
        _form.namaWali = _namaWaliController.text;
        break;
    }
  }

  void _validateDocumentsAndSubmit() {
    // Validate all documents
    final missingDocs = <String>[];
    if (_form.ktpPria == null) missingDocs.add(_tr('doc_ktp_pria'));
    if (_form.ktpWanita == null) missingDocs.add(_tr('doc_ktp_wanita'));
    if (_form.kkPria == null) missingDocs.add(_tr('doc_kk_pria'));
    if (_form.kkWanita == null) missingDocs.add(_tr('doc_kk_wanita'));
    if (_form.aktaLahirPria == null) {
      missingDocs.add(_tr('doc_akta_lahir_pria'));
    }
    if (_form.aktaLahirWanita == null) {
      missingDocs.add(_tr('doc_akta_lahir_wanita'));
    }
    if (_form.suratPengantar == null) {
      missingDocs.add(_tr('doc_surat_pengantar'));
    }
    if (_form.fotoBersama == null) missingDocs.add(_tr('doc_foto_bersama'));

    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localeProvider.isIndonesian
                ? 'Dokumen belum lengkap: ${missingDocs.join(", ")}'
                : 'Missing documents: ${missingDocs.join(", ")}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      setState(() => _currentStep = 3);
      return;
    }

    _submitForm();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
      _serverErrors = null;
    });

    try {
      final api = PublicApiService();
      final result = await api.submitMarriageRegistration(
        formData: _form.toJson(),
        documents: _form.getDocuments(),
      );

      if (!mounted) return;

      if (result.success && result.data != null) {
        // Navigate to success screen
        Navigator.pushReplacementNamed(
          context,
          '/public/marriage/success',
          arguments: {'uuid': result.data, 'locale': _localeProvider},
        );
      } else if (result.isValidationError) {
        setState(() => _serverErrors = result.validationErrors);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _localeProvider.isIndonesian
                  ? 'Data tidak valid, periksa kembali'
                  : 'Invalid data, please check again',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (result.isNetworkError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr('error_network')),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? _tr('error_unknown')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
