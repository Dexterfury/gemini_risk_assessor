import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/discussion_message.dart';
import 'package:gemini_risk_assessor/utilities/gradient_border_container.dart';

class AdditionalDataWidget extends StatelessWidget {
  const AdditionalDataWidget({
    Key? key,
    required this.message,
    required this.isDialog,
  }) : super(key: key);

  final DiscussionMessage message;
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    return isDialog
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Data',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildListSection('Risks', message.additionalData.risks),
                  _buildListSection('Hazards', message.additionalData.hazards),
                  _buildListSection(
                      'Control Measures', message.additionalData.control),
                ],
              ),
            ),
          )
        : GradientBorderContainer(
            child: Card(
              color: Colors.blueGrey[100],
              elevation:
                  0, // Remove shadow as it's now inside another container
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Data',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildListSection('Risks', message.additionalData.risks),
                    _buildListSection(
                        'Hazards', message.additionalData.hazards),
                    _buildListSection(
                        'Control Measures', message.additionalData.control),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildListSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• $item'),
                ))
            .toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}
