class Task {
  final String? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final List<String> teamMemberIds;
  final double progress;
  final bool isCompleted;
  final String userId;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.teamMemberIds,
    this.progress = 0.0,
    this.isCompleted = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'team_member_ids': teamMemberIds,
      'progress': progress,
      'is_completed': isCompleted,
      'user_id': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['due_date']),
      teamMemberIds: List<String>.from(map['team_member_ids']),
      progress: map['progress'],
      isCompleted: map['is_completed'],
      userId: map['user_id'],
    );
  }
}
