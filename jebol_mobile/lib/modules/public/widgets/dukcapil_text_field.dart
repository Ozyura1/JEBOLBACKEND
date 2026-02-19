import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dukcapil-style text field with strict validation.
/// Government-grade input field with proper formatting.
class DukcapilTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final Widget? suffixIcon;
  final bool required;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const DukcapilTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.suffixIcon,
    this.required = false,
    this.onChanged,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF37474F),
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
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: enabled,
          onChanged: onChanged,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

/// NIK input field with auto-formatting.
class NikTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool required;

  const NikTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return DukcapilTextField(
      label: label,
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.number,
      maxLength: 16,
      required: required,
      hint: '16 digit angka',
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
      ],
    );
  }
}

/// Phone number input field with Indonesian format.
class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool required;

  const PhoneTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return DukcapilTextField(
      label: label,
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.phone,
      required: required,
      hint: '08xxxxxxxxxx',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\+]')),
        LengthLimitingTextInputFormatter(15),
      ],
    );
  }
}

/// Uppercase name field (KTP style).
class NameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool required;

  const NameTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return DukcapilTextField(
      label: label,
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.name,
      required: required,
      hint: 'NAMA SESUAI KTP',
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        UpperCaseTextFormatter(),
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s\.\,\-]')),
      ],
    );
  }
}

/// RT/RW input field.
class RtRwTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const RtRwTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DukcapilTextField(
      label: label,
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.number,
      required: true,
      hint: '001',
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
    );
  }
}

/// Date picker field.
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime?) onChanged;
  final String? Function(DateTime?)? validator;
  final String? hint;
  final bool required;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.hint,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorText = validator?.call(value);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF37474F),
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
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  value ??
                  DateTime.now().subtract(const Duration(days: 365 * 20)),
              firstDate: firstDate ?? DateTime(1900),
              lastDate:
                  lastDate ?? DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF1565C0),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : Colors.grey.shade300,
                width: hasError ? 1 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                        : hint ?? 'Pilih tanggal',
                    style: TextStyle(
                      fontSize: 15,
                      color: value != null
                          ? const Color(0xFF212121)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

/// Dropdown field with government styling.
class DukcapilDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String? hint;
  final bool required;

  const DukcapilDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hint,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorText = validator?.call(value);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF37474F),
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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              hint: Text(
                hint ?? 'Pilih',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF212121)),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

/// Uppercase text formatter for KTP-style names.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
