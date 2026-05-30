import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coding_question.dart';
import '../models/user_stats.dart';
import '../models/topic.dart';

class CodingService {
  final _questionCollection = FirebaseFirestore.instance.collection('coding_questions');
  final _topicsCollection = FirebaseFirestore.instance.collection('topics');

  // STREAM ALL CODING QUESTIONS (ordered by date)
  Stream<List<CodingQuestion>> getQuestions() {
    return _questionCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CodingQuestion.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ADD NEW QUESTION
  Future<void> addQuestion(CodingQuestion question) async {
    await _questionCollection.add(question.toMap());
  }

  // FETCH DAILY QUESTION (just the first with 'daily': true)
  Future<CodingQuestion?> fetchDailyQuestion() async {
    final query = await _questionCollection
        .where('daily', isEqualTo: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return CodingQuestion.fromMap(doc.data(), doc.id);
  }

  // FETCH USER STATS
  Future<UserStats?> fetchUserStats(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('summary')
        .get();
    if (!doc.exists) return null;
    return UserStats.fromMap(doc.data()!);
  }

  // FETCH QUICK REVISION TOPICS
  Future<List<Topic>> fetchQuickRevisionTopics() async {
    final query = await _topicsCollection.get();
    return query.docs.map((doc) => Topic.fromMap(doc.data())).toList();
  }
}