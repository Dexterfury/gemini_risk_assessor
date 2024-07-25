class QuizModel {
  final String title;
  final String quizID;
  final String itemID;
  final DateTime createdAt;
  final List<Map<String, dynamic>> questions;

  // constructor
  QuizModel({
    required this.title,
    required this.quizID,
    required this.itemID,
    required this.createdAt,
    required this.questions,
  });

  // factory to map  method
}
