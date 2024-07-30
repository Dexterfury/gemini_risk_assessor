import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';

class PpeItem extends StatelessWidget {
  const PpeItem({
    super.key,
    required this.ppeItem,
    required this.isAdded,
    required this.onTap,
  });

  final PpeModel ppeItem;
  final bool isAdded;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppTheme.cardElevation,
        color: isAdded
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ppeItem.icon,
                    FittedBox(
                      child: Text(
                        ppeItem.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdded && onTap != null)
                const Positioned(
                  top: 5.0,
                  right: 5.0,
                  child: Icon(Icons.check, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
