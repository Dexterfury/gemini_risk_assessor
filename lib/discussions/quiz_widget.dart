import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/discussions/quiz_model.dart';
import 'package:gemini_risk_assessor/discussions/quiz_results_widget.dart';
import 'package:provider/provider.dart';

class QuizWidget extends StatefulWidget {
  final QuizModel quizData;
  final String userUID;
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic> quizResults;

  QuizWidget({
    required this.quizData,
    required this.userUID,
    required this.onSubmit,
    required this.quizResults,
  });

  @override
  _QuizWidgetState createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  Map<int, String> userAnswers = {};
  bool hasUserTakenQuiz = false;

  @override
  void initState() {
    super.initState();
    hasUserTakenQuiz = widget.quizResults.containsKey(widget.userUID);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<DiscussionChatProvider>().isLoadingAnswer;

    return Card(
      color: Colors.blueGrey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Constants.safetyQuiz,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            ...widget.quizData.questions.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> question = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question[Constants.question]}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  ...question[Constants.options].asMap().entries.map((option) {
                    int key = option.key;
                    String optionLetter = String.fromCharCode(65 + key);
                    return RadioListTile<String>(
                      title: Text('$optionLetter. ${option.value}'),
                      value: optionLetter,
                      groupValue: userAnswers[index],
                      onChanged: (value) {
                        setState(() {
                          userAnswers[index] = value!;
                        });
                      },
                    );
                  }).toList(),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed:
                        userAnswers.length == widget.quizData.questions.length
                            ? () {
                                widget.onSubmit({
                                  Constants.userUID: widget.userUID,
                                  Constants.answers: userAnswers,
                                });
                              }
                            : null,
                    child: Text('Submit Quiz'),
                  ),
          ],
        ),
      ),
    );
  }
}
