import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final int difficulty;
  final int? order;
  final DateTime? createdAt;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.difficulty,
    this.order,
    this.createdAt,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      explanation: data['explanation'] ?? '',
      category: data['category'] ?? '',
      difficulty: _parseDifficulty(data['difficulty']),
      order: data['order'] is int ? data['order'] as int : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  static int _parseDifficulty(dynamic value) {
    if (value is int) return value;

    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;

      switch (value.toLowerCase()) {
        case 'easy':
          return 1;
        case 'medium':
          return 2;
        case 'hard':
          return 3;
      }
    }

    return 1;
  }
}
