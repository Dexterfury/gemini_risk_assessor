import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/nearmiss/control_measure.dart';

class AddControlMeasureDialog extends StatefulWidget {
  final ControlMeasure? initialMeasure;
  final Function(ControlMeasure) onAdd;

  const AddControlMeasureDialog({
    Key? key,
    this.initialMeasure,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddControlMeasureDialogState createState() =>
      _AddControlMeasureDialogState();
}

class _AddControlMeasureDialogState extends State<AddControlMeasureDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _measureController;
  late TextEditingController _typeController;
  late TextEditingController _rationaleController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _measureController =
        TextEditingController(text: widget.initialMeasure?.measure ?? '');
    _typeController =
        TextEditingController(text: widget.initialMeasure?.type ?? '');
    _rationaleController =
        TextEditingController(text: widget.initialMeasure?.reason ?? '');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _measureController.dispose();
    _typeController.dispose();
    _rationaleController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: AlertDialog(
        title: Text(
          widget.initialMeasure == null
              ? 'Add Control Measure'
              : 'Edit Control Measure',
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _measureController,
                decoration: InputDecoration(labelText: 'Measure'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _rationaleController,
                decoration: InputDecoration(labelText: 'Reason'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // if his adding a new control measure, then we need to add it to the list of measures
              // if no data is entered, then we need to do nothing
              if (_measureController.text.isEmpty ||
                  _typeController.text.isEmpty ||
                  _rationaleController.text.isEmpty) {
                return;
              }
              // data entere must be atleast 3 characters long
              if (_measureController.text.length < 3 ||
                  _typeController.text.length < 3 ||
                  _rationaleController.text.length < 3) {
                return;
              }

              final newMeasure = ControlMeasure(
                measure: _measureController.text,
                type: _typeController.text,
                reason: _rationaleController.text,
              );
              widget.onAdd(newMeasure);
            },
            child: Text(widget.initialMeasure == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}
