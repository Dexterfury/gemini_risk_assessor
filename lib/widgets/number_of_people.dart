import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:provider/provider.dart';

class NumberOfPeople extends StatelessWidget {
  const NumberOfPeople({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Number of People'),
        Consumer<AssessmentProvider>(
          builder: (context, assessmentProvider, child) {
            final numberOfPeople = assessmentProvider.numberOfPeople;
            return Card(
              child: Row(
                children: [
                  IconButton(
                      onPressed: numberOfPeople == 1
                          ? null
                          : () {
                              assessmentProvider.decrementNumberOfPeople();
                            },
                      icon: const Icon(Icons.remove_circle)),
                  Text(
                    numberOfPeople.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                      onPressed: () {
                        assessmentProvider.incrementNumberOfPeople();
                      },
                      icon: const Icon(Icons.add_circle))
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
