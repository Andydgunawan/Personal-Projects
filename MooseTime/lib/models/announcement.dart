class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> row) {
    return Announcement(
      id: row['id'].toString(),
      title: row['title'] as String,
      body: row['body'] as String,
      date: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  }

  final String id;
  final String title;
  final String body;
  final DateTime date;
}
