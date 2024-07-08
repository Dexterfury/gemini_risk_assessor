import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';

class DisplaySignature extends StatelessWidget {
  const DisplaySignature({
    super.key,
    required this.assessmentProvider,
  });

  final AssessmentProvider assessmentProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.memory(
          assessmentProvider.signatureImage!,
          fit: BoxFit.fill,
          width: 100,
          height: 40,
        ),
        const SizedBox(
          width: 10,
        ),

        GestureDetector(
          onTap: () {
            // reset the signature
            assessmentProvider.resetSignature();
          },
          child: const Icon(Icons.cancel, color: Colors.grey),
        ),
        // GestureDetector(
        //   onTap: () {
        //     // reset the signature
        //     assessmentProvider.resetSignature();
        //   },
        //   child: Container(
        //     padding: const EdgeInsets.all(6.0),
        //     decoration: BoxDecoration(
        //       color: Theme.of(context).dialogBackgroundColor,
        //       borderRadius: BorderRadius.circular(30),
        //       border: Border.all(
        //         width: 1,
        //         color: Colors.grey,
        //       ),
        //     ),
        //     child: const Icon(Icons.clear),
        //   ),
        // )
      ],
    );
  }
}
