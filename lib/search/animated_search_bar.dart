import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:provider/provider.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
  });

  final Function(String) onSearch;

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        _focusNode.requestFocus();
      } else {
        _controller.reverse();
        _focusNode.unfocus();
        _textController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width:
              _animation.value * 200 + 48, // Expand to 200 pixels + icon size
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(!_isExpanded ? Icons.search : Icons.clear_outlined),
                onPressed: _toggleSearch,
              ),
              Expanded(
                child: _isExpanded
                    ? Consumer<TabProvider>(
                        builder: (context, tabProvider, child) {
                          bool clearText = tabProvider.textFocus;
                          if (clearText) {
                            //_focusNode.unfocus();
                            _textController.clear();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: tabProvider.hintText,
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => widget.onSearch(value),
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }
}
