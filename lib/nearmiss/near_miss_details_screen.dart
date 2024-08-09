import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
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
    required this.isAdmin,
    this.groupID = '',
    this.dateTimeFocusNode,
  }) : super(key: key);

  final bool isViewOnly;
  final bool isAdmin;
  final String groupID;
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
                  const SizedBox(height: 10),
                  if (isAdmin && isViewOnly)
                    Align(
                      alignment: Alignment.center,
                      child: _buildDeletNearMissButton(
                        context,
                        nearMiss,
                      ),
                    )
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

  Widget _buildDeletNearMissButton(
      BuildContext context, NearMissModel nearMiss) {
    return MainAppButton(
      icon: FontAwesomeIcons.eraser,
      label: 'Delete Near Miss Report',
      contanerColor: Colors.red,
      borderRadius: 15.0,
      onTap: () async {
        // show dialog if sure to delete
        MyDialogs.showMyAnimatedDialog(
            context: context,
            title: 'Delete Near Miss Report',
            content: 'Are you sure you want to delete this Near Miss Report?',
            actions: [
              TextButton(
                onPressed: () {
                  // pop dialog
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  // pop dialog
                  Navigator.pop(context);
                  _handleDetionateNearMiss(context, nearMiss, groupID);
                },
                child: Text('Yes'),
              ),
            ]);
      },
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

void _handleDetionateNearMiss(
  BuildContext context,
  NearMissModel nearMiss,
  String groupID,
) async {
  final uid = context.read<AuthenticationProvider>().userModel!.uid;
  // show my alert dialog for loading
  MyDialogs.showMyAnimatedDialog(
    context: context,
    title: 'Deleting...',
    loadingIndicator: const SizedBox(
      height: 100,
      width: 100,
      child: LoadingPPEIcons(),
    ),
  );

  await FirebaseMethods.deleteNearMissReport(
    currentUserID: uid,
    groupID: groupID,
    nearMiss: nearMiss,
    onSuccess: () {
      // pop the loading dialog
      Navigator.pop(context);
      Future.delayed(const Duration(seconds: 1)).whenComplete(() {
        showSnackBar(
          context: context,
          message: 'Successful Deleted',
        );
        // pop the screen
        Navigator.pop(context);
      });
    },
    onError: (error) {
      // pop the loading dialog
      Navigator.pop(context);
      showSnackBar(
        context: context,
        message: error.toString(),
      );
    },
  );
}
