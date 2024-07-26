import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/discussions/quiz_model.dart';
import 'package:gemini_risk_assessor/discussions/quiz_reply_preview.dart';
import 'package:gemini_risk_assessor/utilities/gradient_border_container.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';

class QuizResultsWidget extends StatelessWidget {
  final DiscussionMessage message;
  final String userUID;

  QuizResultsWidget({
    required this.message,
    required this.userUID,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> quizResults = message.quizResults;
    final isReplying = message.repliedTo.isNotEmpty;
    return Card(
      color: Colors.blueGrey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReplying) ...[
            QuizReplyPreview(
              message: message,
            )
          ],
          ...quizResults.entries.map((entry) {
            final participantUID = entry.key;
            final participantData = entry.value as Map<String, dynamic>;
            return _buildParticipantResult(
                context, participantUID, participantData);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildParticipantResult(BuildContext context, String participantUID,
      Map<String, dynamic> participantData) {
    final QuizModel quizData = message.quizData;
    int correctAnswers = 0;
    final answers = Map<String, String>.from(
        participantData[Constants.answers] as Map<String, dynamic>);
    final participantName = participantData[Constants.name];
    final participantImage = participantData[Constants.imageUrl];
    final createdAtTimestamp = participantData[Constants.createdAt];
    final createdAtDateTime =
        DateTime.fromMillisecondsSinceEpoch(createdAtTimestamp);
    final time = formatDate(createdAtDateTime, [hh, ':', nn, ' ', am]);

    quizData.questions.asMap().forEach((index, question) {
      final userAnswer = answers[index.toString()];
      final correctAnswer = question[Constants.correctAnswer];
      if (userAnswer == correctAnswer) {
        correctAnswers++;
      }
    });

    final bool allCorrect = correctAnswers == quizData.questions.length;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: DisplayUserImage(
        radius: 20,
        isViewOnly: true,
        imageUrl: participantImage,
        onPressed: () {},
      ),
      title: Text(
        '${participantUID == userUID ? "You" : participantName}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Score: $correctAnswers / ${quizData.questions.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      trailing: allCorrect
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.star, color: Colors.yellow),
            )
          : null, // Add star icon if all answers are correct
    );
  }
}
