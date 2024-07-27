import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/nearmiss/control_measure.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';

class ControlMeasureCard extends StatelessWidget {
  final ControlMeasure controlMeasure;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ControlMeasureCard({
    Key? key,
    required this.controlMeasure,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        controlMeasure.type,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit, size: 20),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete, size: 20),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(controlMeasure.measure),
            SizedBox(height: 8),
            Text(
              'Reason:',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(controlMeasure.reason),
          ],
        ),
      ),
    );
  }
}
