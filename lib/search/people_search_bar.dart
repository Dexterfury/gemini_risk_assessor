import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';

class PeopleSearchBar extends StatefulWidget {
  const PeopleSearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
  });

  final ValueNotifier<String> searchQuery;
  final Function(String) onChanged;

  @override
  State<PeopleSearchBar> createState() => _PeopleSearchBarState();
}

class _PeopleSearchBarState extends State<PeopleSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery.value);
    widget.searchQuery.addListener(_updateControllerValue);
  }

  @override
  void dispose() {
    widget.searchQuery.removeListener(_updateControllerValue);
    _controller.dispose();
    super.dispose();
  }

  void _updateControllerValue() {
    final newValue = widget.searchQuery.value;
    if (_controller.text != newValue) {
      _controller.value = _controller.value.copyWith(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ValueListenableBuilder<String>(
        valueListenable: widget.searchQuery,
        builder: (context, query, _) {
          return TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
              fillColor: AppTheme.getSearchFillTheme(context),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        widget.onChanged('');
                        // remove focus
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: const Icon(Icons.cancel, color: Colors.grey),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
