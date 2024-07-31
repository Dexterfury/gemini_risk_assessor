import 'package:flutter/material.dart';

class NumbersWidget extends StatelessWidget {
  const NumbersWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(
            context,
            '24',
            'Shared',
          ),
          buildDivider(),
          buildButton(
            context,
            '14',
            'Followers',
          ),
          buildDivider(),
          buildButton(
            context,
            '17',
            'Following',
          ),
        ],
      ),
    );
  }
}

Widget buildButton(
  BuildContext context,
  String value,
  String text,
) {
  return MaterialButton(
    padding: const EdgeInsets.symmetric(
      vertical: 4,
    ),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    onPressed: () {},
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}

Widget buildDivider() {
  return SizedBox(
    height: 24,
    child: VerticalDivider(),
  );
}
