import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';

class WeatherButton extends StatelessWidget {
  const WeatherButton({
    super.key,
    required this.title,
    required this.value,
    required this.iconData,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final Function() onChanged;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final capitalizedTitle = title.isNotEmpty
        ? title[0].toUpperCase() + title.substring(1)
        : 'Unknown';
    return SizedBox(
      height: 56.0,
      width: MediaQuery.of(context).size.width / 4,
      child: Card(
        color: value
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).cardColor,
        elevation: AppTheme.cardElevation,
        child: GestureDetector(
          onTap: onChanged,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(iconData),
                  const SizedBox(width: 4),
                  Text(capitalizedTitle),
                  const SizedBox(width: 4),
                  if (value)
                    const Icon(
                      Icons.check,
                      size: 15,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
