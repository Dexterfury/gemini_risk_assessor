import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/action_button.dart';
import 'package:provider/provider.dart';

class AssessmentGridItems extends StatefulWidget {
  final List<String> equipments;
  final List<String> hazards;
  final List<String> risks;
  final List<String> controlMeasures;
  final AssessmentModel? currentModel;

  const AssessmentGridItems({
    super.key,
    required this.equipments,
    required this.hazards,
    required this.risks,
    required this.controlMeasures,
    this.currentModel,
  });

  @override
  State<AssessmentGridItems> createState() => _AssessmentGridItemsState();
}

class _AssessmentGridItemsState extends State<AssessmentGridItems>
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
        _animationController.reverse();
      } else {
        _selectedCategory = category;
        _animationController.forward();
      }
    });
  }

  List<String> _getSelectedList() {
    switch (_selectedCategory) {
      case 'Equipments':
        return widget.equipments;
      case 'Hazards':
        return widget.hazards;
      case 'Risks':
        return widget.risks;
      case 'Control Measures':
        return widget.controlMeasures;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final assessmentProvider = context.read<AssessmentProvider>();
    return Column(
      children: [
        Text(
          'Tap on the category to view its items',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildGridItem('Equipments', Icons.handyman),
            _buildGridItem('Hazards', Icons.warning),
            _buildGridItem('Risks', Icons.security),
            _buildGridItem('Control Measures', Icons.shield),
          ],
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: Card(
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        widget.currentModel != null
                            ? const SizedBox()
                            : IconButton(
                                onPressed: () {
                                  // show dialog to add new item depending on the selected category
                                  MyDialogs.showMyEditAnimatedDialog(
                                    context: context,
                                    title: _selectedCategory ?? '',
                                    maxLength: 500,
                                    hintText:
                                        'Add new ${_selectedCategory ?? ''}',
                                    textAction: "Save",
                                    onActionTap: (value, updatedText) async {
                                      if (value) {
                                        assessmentProvider.addDataItem(
                                          label: _selectedCategory!,
                                          data: updatedText,
                                        );
                                      }
                                    },
                                  );
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.plus,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._getSelectedList().map((item) {
                      // capitalize the first letter of each word
                      String capitalizedItem = item
                          .split(' ')
                          .map((word) =>
                              word[0].toUpperCase() + word.substring(1))
                          .join(' ');
                      return InkWell(
                        onTap: widget.currentModel != null
                            ? null
                            : () {
                                // show animated dialog and to remove item
                                MyDialogs.showMyAnimatedDialog(
                                    context: context,
                                    title: 'Remove item',
                                    content:
                                        'Are you sure to remove\n $capitalizedItem',
                                    actions: [
                                      ActionButton(
                                        label: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ActionButton(
                                        label: const Text(
                                          'Yes',
                                        ),
                                        onPressed: () {
                                          assessmentProvider
                                              .removeDataItem(
                                                label: _selectedCategory!,
                                                data: item,
                                              )
                                              .whenComplete(
                                                () =>
                                                    Navigator.of(context).pop(),
                                              );
                                        },
                                      ),
                                    ]);
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '• $capitalizedItem',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(String title, IconData icon) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => _toggleCategory(title),
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).iconTheme.color,
                ),
                const SizedBox(height: 8),
                FittedBox(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: textStyle18w500.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
