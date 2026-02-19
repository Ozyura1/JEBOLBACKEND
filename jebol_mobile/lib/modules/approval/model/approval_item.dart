class ApprovalItem {
  final String id;
  final String title;
  final String status;

  const ApprovalItem({
    required this.id,
    required this.title,
    required this.status,
  });

  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    return ApprovalItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
