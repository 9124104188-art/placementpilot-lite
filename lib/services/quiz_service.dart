import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/quiz.dart';
import '../models/question.dart';

class QuizService {
  final CollectionReference _quizRef = FirebaseFirestore.instance.collection(
    'quizzes',
  );
  final CollectionReference _questionRef = FirebaseFirestore.instance
      .collection('questions');

  /// Fetch all quiz categories (for showing category cards)
  Future<List<Quiz>> fetchAllQuizzes() async {
    final snap = await _quizRef.get();
    print('Fetched quiz docs: ${snap.docs.length}');
    for (final doc in snap.docs) {
      print('RAW doc: ${doc.data()}');
      final quiz = Quiz.fromFirestore(doc);
      print('Quiz mapped: category="${quiz.category}", title="${quiz.title}"');
    }
    return snap.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
  }

  /// Fetch one quiz document by its Firestore ID
  Future<Quiz?> fetchQuizById(String id) async {
    final doc = await _quizRef.doc(id).get();
    if (!doc.exists) return null;
    return Quiz.fromFirestore(doc);
  }

  /// Fetch all questions for a given category name.
  Future<List<Question>> fetchQuestionsByCategory(String category) async {
    print("Fetching questions for category: $category");

    // First try an exact match query (fast).
    final snap = await _questionRef
        .where('category', isEqualTo: category)
        .get();
    print("Documents found (exact match): ${snap.docs.length}");

    // Map results
    var questions = snap.docs
        .map((doc) => Question.fromFirestore(doc))
        .toList();

    // If nothing matched, fall back to a case-insensitive client-side filter.
    if (questions.isEmpty) {
      final allSnap = await _questionRef.get();
      final lower = category.toLowerCase();
      questions = allSnap.docs
          .map((doc) => Question.fromFirestore(doc))
          .where((q) => q.category.toLowerCase() == lower)
          .toList();
      print("Documents found (case-insensitive fallback): ${questions.length}");
    }

    // Optional: sort questions if your model supports ordering and creation time
    questions.sort((left, right) {
      final leftOrder = left.order ?? 1 << 30;
      final rightOrder = right.order ?? 1 << 30;
      if (leftOrder != rightOrder) return leftOrder.compareTo(rightOrder);

      final leftCreatedAt =
          left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final rightCreatedAt =
          right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final createdAtComparison = leftCreatedAt.compareTo(rightCreatedAt);
      if (createdAtComparison != 0) return createdAtComparison;

      return left.id.compareTo(right.id);
    });

    return questions;
  }

  /// Fetch questions for a category and difficulty level.
  Future<List<Question>> fetchQuestionsByCategoryAndDifficulty(
    String category,
    int difficulty, {
    int limit = 15,
    int? nonce,
  }) async {
    final allQuestions = await fetchQuestionsByCategory(category);
    final filteredQuestions = allQuestions
        .where((question) => question.difficulty == difficulty)
        .toList();

    filteredQuestions.shuffle(
      Random(nonce ?? DateTime.now().millisecondsSinceEpoch),
    );

    final limitedQuestions = filteredQuestions.take(limit).toList();

    print(
      'Filtered questions for category: $category, difficulty: $difficulty, count: ${limitedQuestions.length}',
    );

    return limitedQuestions;
  }
}
