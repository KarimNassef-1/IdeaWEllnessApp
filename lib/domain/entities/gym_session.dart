class GymSession {
  const GymSession({
    required this.id,
    required this.name,
    required this.timeStart,
    required this.timeEnd,
    required this.trainer,
    required this.type,
    this.day,
    this.category,
  });

  final String id;
  final String name;
  final String timeStart;
  final String timeEnd;
  final String trainer;
  final String type;
  final String? day;
  final String? category;

  String get time => timeStart;

  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'time_start': timeStart,
      'time_end': timeEnd,
      'trainer': trainer,
      'type': type,
      'day': day ?? '',
      'category': category ?? '',
    };
  }

  factory GymSession.fromMap(Map<String, dynamic> map) {
    final start = (map['time_start'] ?? map['time'] ?? '').toString();
    final end = (map['time_end'] ?? '').toString();

    return GymSession(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      timeStart: start,
      timeEnd: end.isEmpty ? start : end,
      trainer: (map['trainer'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      day: (map['day'] ?? '').toString().isEmpty ? null : (map['day'] ?? '').toString(),
      category: (map['category'] ?? '').toString().isEmpty
          ? null
          : (map['category'] ?? '').toString(),
    );
  }
}
