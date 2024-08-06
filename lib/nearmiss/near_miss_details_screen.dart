import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/nearmiss/add_control_measure_dialog.dart';
import 'package:gemini_risk_assessor/nearmiss/control_measure.dart';
import 'package:gemini_risk_assessor/nearmiss/control_measures_card.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_model.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:provider/provider.dart';

class NearMissDetailsScreen extends StatelessWidget {
  const NearMissDetailsScreen({
    Key? key,
    this.isViewOnly = false,
    this.dateTimeFocusNode,
  }) : super(key: key);

  final bool isViewOnly;
  final BoardDateTimeInputFocusNode? dateTimeFocusNode;

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Near Miss Details Screen',
      screenClass: 'NearMissDetailsScreen',
    );
    if (dateTimeFocusNode != null) {
      dateTimeFocusNode!.unfocus();
    }
    return Scaffold(
      appBar: MyAppBar(
        leading: BackButton(),
        title: 'Near Miss Details',
      ),
      body: Consumer<NearMissProvider>(
        builder: (context, nearMissProvider, child) {
          final nearMiss = nearMissProvider.nearMiss;

          if (nearMiss == null) {
            return Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateTimeRow(nearMiss),
                  const SizedBox(height: 20),
                  _buildDescriptionSection(nearMiss),
                  const SizedBox(height: 20),
                  _buildControlMeasuresSection(
                      context, nearMissProvider, nearMiss),
                  const SizedBox(height: 20),
                  if (!isViewOnly) _buildSaveButton(context, nearMissProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeRow(NearMissModel nearMiss) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(FontAwesomeIcons.calendarDay, color: Colors.blue),
        Text(
          nearMiss.dateTime,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(NearMissModel nearMiss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          nearMiss.description,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildControlMeasuresSection(
      BuildContext context, NearMissProvider provider, NearMissModel nearMiss) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Control Measures:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (!isViewOnly)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () =>
                    _showAddControlMeasureDialog(context, provider),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: nearMiss.controlMeasures.length,
          itemBuilder: (context, index) {
            return ControlMeasureCard(
              controlMeasure: nearMiss.controlMeasures[index],
              onDelete: isViewOnly
                  ? null
                  : () => _deleteControlMeasure(context, provider, index),
              onEdit: isViewOnly
                  ? null
                  : () => _editControlMeasure(context, provider, index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    NearMissProvider provider,
  ) {
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: ElevatedButton(
        child: Text('Save Near Miss Report'),
        onPressed: () async {
          await context.read<NearMissProvider>().saveNearMiss(
            onSuccess: () {
              showSnackBar(
                context: context,
                message: 'Near Miss Report Saved',
              );
            },
            onError: (error) {
              showSnackBar(
                context: context,
                message: '$error',
              );
            },
          );

          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddControlMeasureDialog(
    BuildContext context,
    NearMissProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddControlMeasureDialog(
        onAdd: (ControlMeasure newMeasure) {
          provider.addControlMeasure(newMeasure);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteControlMeasure(
    BuildContext context,
    NearMissProvider provider,
    int index,
  ) {
    MyDialogs.showMyAnimatedDialog(
        context: context,
        title: 'Delete',
        content: 'Are you sure to Delete this item?',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteControlMeasure(index);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.deleteControlMeasure(index);
              Navigator.pop(context);
            },
            child: Text(
              'Yes',
            ),
          ),
        ]);
  }

  void _editControlMeasure(
      BuildContext context, NearMissProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AddControlMeasureDialog(
        initialMeasure: provider.nearMiss!.controlMeasures[index],
        onAdd: (ControlMeasure updatedMeasure) {
          provider.updateControlMeasure(index, updatedMeasure);
          Navigator.pop(context);
        },
      ),
    );
  }
}
