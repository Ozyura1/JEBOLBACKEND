class MonitoringStat {
  final String label;
  final String value;

  const MonitoringStat({required this.label, required this.value});

  factory MonitoringStat.fromJson(Map<String, dynamic> json) {
    return MonitoringStat(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}
