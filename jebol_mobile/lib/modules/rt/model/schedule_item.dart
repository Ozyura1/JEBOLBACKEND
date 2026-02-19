class ScheduleItem {
  final String id;
  final String title;
  final String submissionType; // 'ktp' or 'ikd'
  final String date;
  final String location;

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.submissionType,
    required this.date,
    required this.location,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    // Parse scheduled_at datetime
    final scheduledAt = json['scheduled_at']?.toString() ?? '';
    final dateTime = scheduledAt.isNotEmpty
        ? DateTime.tryParse(scheduledAt)
        : null;

    // Format date as "dd/MM/yyyy HH:mm" or just date if parsing fails
    final formattedDate = dateTime != null
        ? '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
        : scheduledAt;

    return ScheduleItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      submissionType: json['submission_type']?.toString() ?? 'ktp',
      date: formattedDate,
      location: json['schedule_notes']?.toString() ?? 'Lokasi belum ditentukan',
    );
  }
}
