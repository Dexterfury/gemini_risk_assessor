import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.icon,
    required this.label,
    this.labelColor = Colors.white,
    this.containerColor,
    this.borderRadius = 10.0,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color labelColor;
  final Color? containerColor;
  final double borderRadius;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final btnColor = containerColor ?? Theme.of(context).primaryColor;
    return Card(
      color: btnColor,
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
