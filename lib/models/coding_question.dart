import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class CodingQuestion {
  final String id;
  final String title;
  final String description;
  final String difficulty; // "Easy", "Medium", "Hard"
  final DateTime date;
  final String sampleInput;
  final String sampleOutput;

  CodingQuestion({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.date,
    required this.sampleInput,
    required this.sampleOutput,
  });

  // Firestore serialization
  factory CodingQuestion.fromMap(Map<String, dynamic> map, String docId) {
    // date in Firestore can be a Timestamp or a native DateTime (or missing)
    DateTime parsedDate;
    final rawDate = map['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      try {
        parsedDate = DateTime.parse(rawDate);
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return CodingQuestion(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      date: parsedDate,
      sampleInput: map['sampleInput'] ?? '',
      sampleOutput: map['sampleOutput'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'date': Timestamp.fromDate(date),
      'sampleInput': sampleInput,
      'sampleOutput': sampleOutput,
    };
  }
}
