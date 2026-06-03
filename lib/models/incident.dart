class Incident {
  Incident({
    required this.id,
    required this.category,
    required this.title,
    required this.status,
    required this.createdAt,
    this.description,
    this.confirmationCount = 0,
  });

  final String id;
  final String category;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;
  final int confirmationCount;

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'other',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      confirmationCount: (json['confirmation_count'] as num?)?.toInt() ?? 0,
    );
  }
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  final seconds = diff.inSeconds;
  if (seconds < 60) return '${seconds}s ago';
  if (seconds < 3600) return '${diff.inMinutes}m ago';
  if (seconds < 86400) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
