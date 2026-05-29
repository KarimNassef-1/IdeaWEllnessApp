class ExerciseCategory {
  const ExerciseCategory({
    required this.exerciseCategoryId,
    required this.categoryName,
    this.iconClass,
  });

  final int exerciseCategoryId;
  final String categoryName;
  final String? iconClass;

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) =>
      ExerciseCategory(
        exerciseCategoryId: json['exerciseCategoryId'] as int,
        categoryName: json['categoryName'] as String? ?? '',
        iconClass: json['iconClass'] as String?,
      );
}

class MuscleGroupInfo {
  const MuscleGroupInfo({
    required this.muscleGroupId,
    required this.muscleGroupName,
    required this.bodyPart,
    required this.isPrimary,
  });

  final int muscleGroupId;
  final String muscleGroupName;
  final String bodyPart;
  final bool isPrimary;

  factory MuscleGroupInfo.fromJson(Map<String, dynamic> json) => MuscleGroupInfo(
        muscleGroupId: json['muscleGroupId'] as int,
        muscleGroupName: json['muscleGroupName'] as String? ?? '',
        bodyPart: json['bodyPart'] as String? ?? '',
        isPrimary: json['isPrimary'] as bool? ?? false,
      );
}

class ExerciseListItem {
  const ExerciseListItem({
    required this.exerciseId,
    required this.exerciseName,
    required this.categoryName,
    required this.difficulty,
    this.photoUrl,
    this.equipment,
    this.primaryMuscles = const [],
  });

  final String exerciseId;
  final String exerciseName;
  final String categoryName;
  final int difficulty;
  final String? photoUrl;
  final String? equipment;
  final List<String> primaryMuscles;

  String get difficultyLabel => switch (difficulty) {
        1 => 'Beginner',
        2 => 'Intermediate',
        3 => 'Advanced',
        _ => 'All Levels',
      };

  factory ExerciseListItem.fromJson(Map<String, dynamic> json) => ExerciseListItem(
        exerciseId: json['exerciseId'] as String? ?? '',
        exerciseName: json['exerciseName'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        difficulty: json['difficulty'] as int? ?? 1,
        photoUrl: json['photoUrl'] as String?,
        equipment: json['equipment'] as String?,
        primaryMuscles: ((json['primaryMuscles'] as List<dynamic>?) ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

class ExerciseDetail extends ExerciseListItem {
  const ExerciseDetail({
    required super.exerciseId,
    required super.exerciseName,
    required super.categoryName,
    required super.difficulty,
    super.photoUrl,
    super.equipment,
    super.primaryMuscles,
    this.description,
    this.instructions,
    this.videoUrl,
    this.muscleGroups = const [],
  });

  final String? description;
  final String? instructions;
  final String? videoUrl;
  final List<MuscleGroupInfo> muscleGroups;

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) => ExerciseDetail(
        exerciseId: json['exerciseId'] as String? ?? '',
        exerciseName: json['exerciseName'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        difficulty: json['difficulty'] as int? ?? 1,
        photoUrl: json['photoUrl'] as String?,
        equipment: json['equipment'] as String?,
        primaryMuscles: ((json['primaryMuscles'] as List<dynamic>?) ?? [])
            .map((e) => e.toString())
            .toList(),
        description: json['description'] as String?,
        instructions: json['instructions'] as String?,
        videoUrl: json['videoUrl'] as String?,
        muscleGroups: ((json['muscleGroups'] as List<dynamic>?) ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MuscleGroupInfo.fromJson)
            .toList(),
      );
}
