import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/quiz_model.dart';

class QuizResultsWidget extends StatelessWidget {
  final QuizModel quizData;
  final Map<String, dynamic> quizResults;
  final String userUID;

  QuizResultsWidget({
    required this.quizData,
    required this.quizResults,
    required this.userUID,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ...quizResults.entries.map((entry) {
              final participantUID = entry.key;
              final participantResult = entry.value as Map<String, dynamic>;
              return _buildParticipantResult(
                  context, participantUID, participantResult);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantResult(BuildContext context, String participantUID,
      Map<String, dynamic> participantResult) {
    int correctAnswers = 0;
    final answers = Map<String, String>.from(
        participantResult[Constants.answers] as Map<String, dynamic>);

    quizData.questions.asMap().forEach((index, question) {
      final userAnswer = answers[index.toString()];
      final correctAnswer = question[Constants.correctAnswer];
      if (userAnswer == correctAnswer) {
        correctAnswers++;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participant: ${participantUID == userUID ? "You" : participantUID}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'Score: $correctAnswers / ${quizData.questions.length}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
