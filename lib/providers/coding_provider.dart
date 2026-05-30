import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/coding_service.dart';
import '../models/coding_question.dart';
import '../models/topic.dart';
import '../models/user_stats.dart';
import 'auth_provider.dart';

final codingServiceProvider = Provider<CodingService>((ref) => CodingService());

final codingQuestionsProvider = StreamProvider<List<CodingQuestion>>((ref) {
  return ref.watch(codingServiceProvider).getQuestions();
});

final dailyQuestionProvider = FutureProvider<CodingQuestion?>((ref) {
  return ref.watch(codingServiceProvider).fetchDailyQuestion();
});

final quickRevisionTopicsProvider = FutureProvider<List<Topic>>((ref) {
  return ref.watch(codingServiceProvider).fetchQuickRevisionTopics();
});

final userStatsProvider = FutureProvider<UserStats?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;

  if (user == null) {
    return null;
  }

  return ref.watch(codingServiceProvider).fetchUserStats(user.uid);
});
