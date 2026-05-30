class Topic {
  final String name;

  Topic({required this.name});

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(name: map['name'] ?? '');
  }
}