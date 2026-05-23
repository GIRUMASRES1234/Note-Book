class NoteModel {
  final String id;
  final String title;
  final String content;
  final String subject; // ✅ NEW
  final DateTime createdAt;
  final bool isPinned;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.subject,
    required this.createdAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "content": content,
      "subject": subject, // ✅ NEW
      "createdAt": createdAt.toIso8601String(),
      "isPinned": isPinned,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map["id"],
      title: map["title"],
      content: map["content"],
      subject: map["subject"] ?? "General", // ✅ NEW (default)
      createdAt: DateTime.parse(map["createdAt"]),
      isPinned: map["isPinned"] ?? false,
    );
  }
}
