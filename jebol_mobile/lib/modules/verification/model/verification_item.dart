class VerificationItem {
  final String id;
  final String title;
  final String status;

  const VerificationItem({
    required this.id,
    required this.title,
    required this.status,
  });

  factory VerificationItem.fromJson(Map<String, dynamic> json) {
    return VerificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
