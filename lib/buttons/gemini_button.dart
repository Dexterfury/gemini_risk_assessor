import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';

class GeminiButton extends StatefulWidget {
  const GeminiButton({
    super.key,
    required this.label,
    this.contanerColor = Colors.white,
    this.borderRadius = 10.0,
    required this.onTap,
  });

  final String label;
  final Color? contanerColor;
  final double borderRadius;
  final Function() onTap;

  @override
  State<GeminiButton> createState() => _GeminiButtonState();
}

class _GeminiButtonState extends State<GeminiButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.contanerColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AssetsManager.geminiLogo1, height: 30, width: 40),
              const SizedBox(
                width: 8.0,
              ),
              Text(
                widget.label,
                style: textStyle18Bold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
