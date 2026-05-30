import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final double accuracy;
  final Timestamp completedAt;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.accuracy,
    required this.completedAt,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map, String id) {
    return QuizResult(
      id: id,
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      score: map['score'] ?? 0,
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      completedAt: map['completedAt'] ?? Timestamp.now(),
    );
  }
}