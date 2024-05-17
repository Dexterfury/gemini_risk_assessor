import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? // cupertinosearchbar
        CupertinoSearchTextField(
            placeholder: Constants.search,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              print(value);
            },
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const TextField(
                decoration: InputDecoration(
              hintText: Constants.search,
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            )));
  }
}
