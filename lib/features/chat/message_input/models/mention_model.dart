class MentionModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final MentionType type;

  MentionModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.type = MentionType.bot,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'type': type.name,
    };
  }

  factory MentionModel.fromMap(Map<String, dynamic> e) {
    return MentionModel(
      id: e['id'] ?? 'id null',
      name: e['name'] ?? 'name null',
      avatarUrl: e['avatarUrl'] as String?,
    );
  }
}

enum MentionType {
  user,
  bot,
}
