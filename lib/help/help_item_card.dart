import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/help/help_item.dart';

class HelpItemCard extends StatelessWidget {
  final HelpItem helpItem;

  const HelpItemCard({super.key, required this.helpItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => helpItem.detailScreen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline,
                  size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                helpItem.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                helpItem.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
