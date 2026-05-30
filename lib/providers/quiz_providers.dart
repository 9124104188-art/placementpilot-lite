import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quiz_service.dart';
import '../models/quiz.dart';
import '../models/question.dart';

// Service instance provider (singleton for clean injection)
final quizServiceProvider = Provider<QuizService>((ref) => QuizService());

// All quizzes provider
final allQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  final service = ref.watch(quizServiceProvider);
  return service.fetchAllQuizzes();
});

// Selected quiz provider by ID
final selectedQuizProvider = FutureProvider.family<Quiz?, String>((
  ref,
  quizId,
) async {
  final service = ref.watch(quizServiceProvider);
  return service.fetchQuizById(quizId);
});

// Questions for category/quiz
final questionsByCategoryProvider =
    FutureProvider.family<List<Question>, String>((ref, category) async {
      final service = ref.watch(quizServiceProvider);
      return service.fetchQuestionsByCategory(category);
    });

// Questions for category + difficulty, capped to 15
final questionsByCategoryAndDifficultyProvider =
    FutureProvider.family<
      List<Question>,
      ({String category, int difficulty, int nonce})
    >((ref, params) async {
      final service = ref.watch(quizServiceProvider);
      return service.fetchQuestionsByCategoryAndDifficulty(
        params.category,
        params.difficulty,
        nonce: params.nonce,
      );
    });
