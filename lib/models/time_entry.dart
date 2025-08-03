class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final int minutes;
  final DateTime date;
  final String notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.minutes,
    required this.date,
    required this.notes,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) => TimeEntry(
    id: json['id'],
    projectId: json['projectId'],
    taskId: json['taskId'],
    minutes: json['minutes'],
    date: DateTime.parse(json['date']),
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'taskId': taskId,
    'minutes': minutes,
    'date': date.toIso8601String(),
    'notes': notes,
  };
}
