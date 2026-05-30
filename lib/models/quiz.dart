class Quiz {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int totalQuestions;
  final DateTime? createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.totalQuestions,
    this.createdAt,
  });

  // ADD THIS:
  factory Quiz.fromFirestore(dynamic doc) {

    
    final data = doc.data() as Map<String, dynamic>;

    print("ACTUAL FIRESTORE KEYS:");
for (final k in data.keys) {
  print("-> '$k'");
}
    return Quiz(
      
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      createdAt: data['createdAt']?.toDate(), // handles Timestamp/DateTime
    );
  }
}