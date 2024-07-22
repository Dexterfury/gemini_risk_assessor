import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';

class GeminiFloatingChatButton extends StatefulWidget {
  final VoidCallback onPressed;
  final ChatButtonSize size;
  final Color color;
  final Color iconColor;
  final IconData icon;

  const GeminiFloatingChatButton({
    super.key,
    required this.onPressed,
    this.size = ChatButtonSize.large,
    this.color = Colors.white,
    this.iconColor = Colors.black,
    this.icon = Icons.chat,
  });

  @override
  State<GeminiFloatingChatButton> createState() =>
      _GeminiFloatingChatButtonState();
}

class _GeminiFloatingChatButtonState extends State<GeminiFloatingChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get buttonSize {
    switch (widget.size) {
      case ChatButtonSize.small:
        return 40.0;
      case ChatButtonSize.medium:
        return 56.0;
      case ChatButtonSize.large:
        return 70.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(top: _animation.value),
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: FloatingActionButton(
                onPressed: widget.onPressed,
                backgroundColor: widget.color,
                elevation: 4.0,
                highlightElevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonSize / 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundColor: widget.color,
                    backgroundImage: AssetImage(AssetsManager.geminiLogo1),
                  ),
                )

                // Icon(widget.icon,
                //     color: widget.iconColor, size: buttonSize * 0.5),
                ),
          ),
        );
      },
    );
  }
}
