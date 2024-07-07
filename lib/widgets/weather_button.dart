import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        decoration: BoxDecoration(
          color: value
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
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
    );
  }
}
