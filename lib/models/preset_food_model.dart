class PresetFood {
  final int? id;
  final String title;
  final String description;

  PresetFood({
    this.id,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
    };
  }

  factory PresetFood.fromMap(Map<String, dynamic> map) {
    return PresetFood(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  String get displayText {
    if (description.trim().isEmpty) {
      return title.trim();
    }
    return '${title.trim()} ${description.trim()}';
  }

  PresetFood copyWith({
    int? id,
    String? title,
    String? description,
  }) {
    return PresetFood(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
