class Task {
  String id;
  String title;
  DateTime date;
  String priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.priority,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
