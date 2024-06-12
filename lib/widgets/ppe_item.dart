import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';

class PpeItem extends StatelessWidget {
  const PpeItem({
    super.key,
    required this.ppeItem,
    required this.isAdded,
    required this.onTap,
  });

  final PpeModel ppeItem;
  final bool isAdded;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: isAdded ? Theme.of(context).highlightColor : null,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 4.0,
            right: 4.0,
          ),
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
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isAdded
                  ? const Positioned(
                      top: 5.0,
                      right: 5.0,
                      child: Icon(
                        Icons.check,
                        size: 16,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
