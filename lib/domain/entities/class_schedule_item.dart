class ClassScheduleItem {
  const ClassScheduleItem({
    required this.gymClassId,
    required this.className,
    required this.timeStart,
    required this.timeEnd,
    required this.branchName,
    this.coachName,
    this.coachPhotoUrl,
    this.capacity,
    this.photoUrl,
  });

  final String gymClassId;
  final String className;
  final String timeStart;
  final String timeEnd;
  final String branchName;
  final String? coachName;
  final String? coachPhotoUrl;
  final int? capacity;
  final String? photoUrl;

  /// Converts to the map format expected by the existing view-all screen.
  Map<String, String> toMap() => {
    'id': gymClassId,
    'name': className,
    'time_start': timeStart,
    'time_end': timeEnd,
    'trainer': coachName ?? '',
    'type': '',
    'day': '',
    'category': '',
  };

  factory ClassScheduleItem.fromJson(Map<String, dynamic> json) {
    return ClassScheduleItem(
      gymClassId:    json['gymClassId']    as String? ?? '',
      className:     json['className']     as String? ?? '',
      timeStart:     json['timeStart']     as String? ?? '',
      timeEnd:       json['timeEnd']       as String? ?? '',
      branchName:    json['branchName']    as String? ?? '',
      coachName:     json['coachName']     as String?,
      coachPhotoUrl: json['coachPhotoUrl'] as String?,
      capacity:      json['capacity']      as int?,
      photoUrl:      json['photoUrl']      as String?,
    );
  }
}

class TodayClasses {
  const TodayClasses({required this.myClasses, required this.branchClasses});

  final List<ClassScheduleItem> myClasses;
  final List<ClassScheduleItem> branchClasses;

  factory TodayClasses.fromJson(Map<String, dynamic> json) {
    List<ClassScheduleItem> parse(String key) =>
        ((json[key] as List<dynamic>?) ?? [])
            .whereType<Map<String, dynamic>>()
            .map(ClassScheduleItem.fromJson)
            .toList();

    return TodayClasses(
      myClasses:     parse('myClasses'),
      branchClasses: parse('branchClasses'),
    );
  }
}
