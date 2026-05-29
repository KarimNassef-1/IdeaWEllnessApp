class WorkoutPlanListItem {
  const WorkoutPlanListItem({
    required this.memberWorkoutPlanId,
    required this.planName,
    required this.exerciseCount,
    this.dayOfWeek,
  });

  final String memberWorkoutPlanId;
  final String planName;
  final int exerciseCount;
  final int? dayOfWeek;

  String get dayLabel {
    if (dayOfWeek == null) return 'Any Day';
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek! % 7];
  }

  factory WorkoutPlanListItem.fromJson(Map<String, dynamic> json) =>
      WorkoutPlanListItem(
        memberWorkoutPlanId: json['memberWorkoutPlanId'] as String? ?? '',
        planName: json['planName'] as String? ?? '',
        exerciseCount: json['exerciseCount'] as int? ?? 0,
        dayOfWeek: json['dayOfWeek'] as int?,
      );
}

class WorkoutPlanExerciseItem {
  const WorkoutPlanExerciseItem({
    required this.memberWorkoutPlanExerciseId,
    required this.exerciseId,
    required this.exerciseName,
    required this.categoryName,
    required this.sortOrder,
    this.photoUrl,
    this.sets,
    this.reps,
    this.durationSeconds,
    this.restSeconds,
  });

  final String memberWorkoutPlanExerciseId;
  final String exerciseId;
  final String exerciseName;
  final String categoryName;
  final int sortOrder;
  final String? photoUrl;
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final int? restSeconds;

  String get volumeLabel {
    if (sets != null && reps != null) return '$sets × $reps reps';
    if (sets != null) return '$sets sets';
    if (durationSeconds != null) return '${durationSeconds}s';
    return '';
  }

  factory WorkoutPlanExerciseItem.fromJson(Map<String, dynamic> json) =>
      WorkoutPlanExerciseItem(
        memberWorkoutPlanExerciseId:
            json['memberWorkoutPlanExerciseId'] as String? ?? '',
        exerciseId: json['exerciseId'] as String? ?? '',
        exerciseName: json['exerciseName'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
        photoUrl: json['photoUrl'] as String?,
        sets: json['sets'] as int?,
        reps: json['reps'] as int?,
        durationSeconds: json['durationSeconds'] as int?,
        restSeconds: json['restSeconds'] as int?,
      );
}

class WorkoutPlanDetail extends WorkoutPlanListItem {
  const WorkoutPlanDetail({
    required super.memberWorkoutPlanId,
    required super.planName,
    required super.exerciseCount,
    super.dayOfWeek,
    this.exercises = const [],
  });

  final List<WorkoutPlanExerciseItem> exercises;

  factory WorkoutPlanDetail.fromJson(Map<String, dynamic> json) =>
      WorkoutPlanDetail(
        memberWorkoutPlanId: json['memberWorkoutPlanId'] as String? ?? '',
        planName: json['planName'] as String? ?? '',
        exerciseCount: json['exerciseCount'] as int? ?? 0,
        dayOfWeek: json['dayOfWeek'] as int?,
        exercises: ((json['exercises'] as List<dynamic>?) ?? [])
            .whereType<Map<String, dynamic>>()
            .map(WorkoutPlanExerciseItem.fromJson)
            .toList(),
      );
}
