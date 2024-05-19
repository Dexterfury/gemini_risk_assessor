import 'package:flutter/material.dart';

class NumberOfPeople extends StatelessWidget {
  const NumberOfPeople({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Number of People'),
            Card(
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        print('pressed -');
                      },
                      icon: const Icon(Icons.remove_circle)),
                  Text('1'),
                  IconButton(
                      onPressed: () {
                        print('pressed +');
                      },
                      icon: const Icon(Icons.add_circle))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
