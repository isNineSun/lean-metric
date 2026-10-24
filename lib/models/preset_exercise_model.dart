enum ExerciseType {
  aerobic, // 有氧
  strength, // 力量训练
}

class PresetExercise {
  final int? id;
  final String title;
  final String capacity;
  final ExerciseType type;

  PresetExercise({
    this.id,
    required this.title,
    required this.capacity,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'capacity': capacity,
      'type': type.name,
    };
  }

  factory PresetExercise.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'strength';
    return PresetExercise(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      capacity: map['capacity'] as String? ?? '',
      type: typeStr == 'aerobic' ? ExerciseType.aerobic : ExerciseType.strength,
    );
  }

  String get typeLabel {
    return type == ExerciseType.aerobic ? '有氧' : '力量';
  }

  String get displayText {
    final prefix = '[$typeLabel]';
    if (capacity.trim().isEmpty) {
      return '$prefix ${title.trim()}';
    }
    return '$prefix ${title.trim()} ${capacity.trim()}';
  }

  PresetExercise copyWith({
    int? id,
    String? title,
    String? capacity,
    ExerciseType? type,
  }) {
    return PresetExercise(
      id: id ?? this.id,
      title: title ?? this.title,
      capacity: capacity ?? this.capacity,
      type: type ?? this.type,
    );
  }
}
