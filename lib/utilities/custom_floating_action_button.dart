import 'package:flutter/material.dart';

class CustomFloatingActionBubble extends AnimatedWidget {
  const CustomFloatingActionBubble({
    Key? key,
    required this.items,
    required this.onPress,
    required this.iconColor,
    required this.backGroundColor,
    required Animation animation,
    this.herotag,
    this.closedImage,
    this.openIcon,
  }) : super(listenable: animation, key: key);

  final List<Bubble> items;
  final void Function() onPress;
  final Object? herotag;
  final ImageProvider? closedImage;
  final IconData? openIcon;
  final Color iconColor;
  final Color backGroundColor;

  get _animation => listenable;

  Widget buildItem(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    TextDirection textDirection = Directionality.of(context);
    double animationDirection = textDirection == TextDirection.ltr ? -1 : 1;

    final transform = Matrix4.translationValues(
      animationDirection *
          (screenWidth - _animation.value * screenWidth) *
          ((items.length - index) / 4),
      0.0,
      0.0,
    );

    return Align(
      alignment: textDirection == TextDirection.ltr
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Transform(
        transform: transform,
        child: Opacity(
          opacity: _animation.value,
          child: BubbleMenu(items[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: _animation.value == 0,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12.0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: buildItem,
          ),
        ),
        FloatingActionButton(
          shape: const CircleBorder(),
          heroTag: herotag ?? const _DefaultHeroTag(),
          backgroundColor: backGroundColor,
          onPressed: onPress,
          child: _animation.value > 0.5
              ? Icon(
                  openIcon ?? Icons.close,
                  color: iconColor,
                )
              : closedImage != null
                  ? Image(
                      image: closedImage!,
                      width: 40,
                      height: 40,
                      //color: iconColor,
                    )
                  : Icon(
                      Icons.add,
                      color: iconColor,
                    ),
        ),
      ],
    );
  }
}

/// Creates a bubble item for floating action menu button.
class Bubble {
  const Bubble({
    required IconData icon,
    required Color iconColor,
    required String title,
    required TextStyle titleStyle,
    required Color bubbleColor,
    required this.onPress,
  })  : _icon = icon,
        _iconColor = iconColor,
        _title = title,
        _titleStyle = titleStyle,
        _bubbleColor = bubbleColor;

  final IconData _icon;
  final Color _iconColor;
  final String _title;
  final TextStyle _titleStyle;
  final Color _bubbleColor;
  final void Function() onPress;
}

/// Creates a bubble menu for all the items for floating action menu button.
class BubbleMenu extends StatelessWidget {
  const BubbleMenu(this.item, {Key? key}) : super(key: key);

  final Bubble item;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.only(top: 11, bottom: 13, left: 32, right: 32),
      color: item._bubbleColor,
      splashColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.1),
      elevation: 2,
      highlightElevation: 2,
      disabledColor: item._bubbleColor,
      onPressed: item.onPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            item._icon,
            color: item._iconColor,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            item._title,
            style: item._titleStyle,
          ),
        ],
      ),
    );
  }
}

/// Creates a Default hero tag for the floating action bubble.
class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionBubble tag>';
}
