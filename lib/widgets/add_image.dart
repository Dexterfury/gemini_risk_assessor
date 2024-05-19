import 'package:flutter/material.dart';

class AddImage extends StatefulWidget {
  const AddImage({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  bool hovered = false;
  bool tappedDown = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          hovered = false;
        });
      },
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            tappedDown = true;
          });
        },
        onTapUp: (details) {
          setState(() {
            tappedDown = false;
          });
          widget.onTap();
        },
        child: SizedBox(
          width: 100,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[100],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
