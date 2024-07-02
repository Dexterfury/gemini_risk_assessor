import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  const MySearchBar({
    super.key,
    required this.onSearch,
  });

  final Function(String) onSearch;

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  TextEditingController controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = controller.text.isNotEmpty;
    });
  }

  void _clearSearch() {
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: TextField(
        controller: controller,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Search...',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: _showClearButton
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
