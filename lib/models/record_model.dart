import 'dart:convert';

class Record {
  final int? id;
  final DateTime date;

  final double? weight;
  final bool isFasting;

  final String? sleepStart;
  final String? sleepEnd;
  final int? sleepDurationMinutes;

  final int? steps;

  final String breakfast;
  final String lunch;
  final String dinner;
  final String otherFood;

  final String exercise;
  final String status;

  final List<String> specialCases;
  final String specialNote;

  Record({
    this.id,
    required this.date,
    this.weight,
    required this.isFasting,
    this.sleepStart,
    this.sleepEnd,
    this.sleepDurationMinutes,
    this.steps,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.otherFood,
    required this.exercise,
    required this.status,
    required this.specialCases,
    required this.specialNote,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'isFasting': isFasting ? 1 : 0,
      'sleepStart': sleepStart,
      'sleepEnd': sleepEnd,
      'sleepDurationMinutes': sleepDurationMinutes,
      'steps': steps,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'otherFood': otherFood,
      'exercise': exercise,
      'status': status,
      'specialCases': jsonEncode(specialCases),
      'specialNote': specialNote,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      weight: (map['weight'] as num?)?.toDouble(),
      isFasting: (map['isFasting'] as int?) == 1,
      sleepStart: map['sleepStart'] as String?,
      sleepEnd: map['sleepEnd'] as String?,
      sleepDurationMinutes: map['sleepDurationMinutes'] as int?,
      steps: map['steps'] as int?,
      breakfast: map['breakfast'] as String? ?? '',
      lunch: map['lunch'] as String? ?? '',
      dinner: map['dinner'] as String? ?? '',
      otherFood: map['otherFood'] as String? ?? '',
      exercise: map['exercise'] as String? ?? '',
      status: map['status'] as String? ?? '',
      specialCases: map['specialCases'] != null
          ? List<String>.from(
              jsonDecode(map['specialCases'] as String) as List)
          : [],
      specialNote: map['specialNote'] as String? ?? '',
    );
  }

  Record copyWith({
    int? id,
    DateTime? date,
    double? weight,
    bool? isFasting,
    String? sleepStart,
    String? sleepEnd,
    int? sleepDurationMinutes,
    int? steps,
    String? breakfast,
    String? lunch,
    String? dinner,
    String? otherFood,
    String? exercise,
    String? status,
    List<String>? specialCases,
    String? specialNote,
  }) {
    return Record(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      isFasting: isFasting ?? this.isFasting,
      sleepStart: sleepStart ?? this.sleepStart,
      sleepEnd: sleepEnd ?? this.sleepEnd,
      sleepDurationMinutes:
          sleepDurationMinutes ?? this.sleepDurationMinutes,
      steps: steps ?? this.steps,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      otherFood: otherFood ?? this.otherFood,
      exercise: exercise ?? this.exercise,
      status: status ?? this.status,
      specialCases: specialCases ?? List<String>.from(this.specialCases),
      specialNote: specialNote ?? this.specialNote,
    );
  }
}
