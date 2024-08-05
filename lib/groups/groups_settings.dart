import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/widgets/settings_switch_list_tile.dart';

class GroupSettingsScreen extends StatefulWidget {
  final bool isNew;
  final DataSettings initialSettings;
  final Function(DataSettings) onSave;

  const GroupSettingsScreen({
    super.key,
    required this.isNew,
    required this.initialSettings,
    required this.onSave,
  });

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late DataSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView(
      screenName: 'Group Settings Screen',
      screenClass: 'GroupSettingsScreen',
    );
    _currentSettings = DataSettings(
      requestToReadTerms: widget.initialSettings.requestToReadTerms,
      allowSharing: widget.initialSettings.allowSharing,
      allowCreate: widget.initialSettings.allowCreate,
      groupTerms: widget.initialSettings.groupTerms,
    );
  }

  void _showTermsEditDialog(BuildContext context, {bool fromSwitch = false}) {
    MyDialogs.animatedEditTermsDialog(
      context: context,
      initialTerms: _currentSettings.groupTerms,
      action: (String newTerms) {
        if (newTerms.length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Terms must be at least 10 characters long.')),
          );
          setState(() {
            if (fromSwitch) {
              _currentSettings.requestToReadTerms = false;
            }
          });
        } else {
          setState(() {
            _currentSettings.groupTerms = newTerms;
            if (fromSwitch) {
              _currentSettings.requestToReadTerms = true;
            }
          });
        }
      },
    );
  }

  void _handleRequestToReadChange(bool value) {
    if (value) {
      if (_currentSettings.groupTerms.length < 10) {
        _showTermsEditDialog(context, fromSwitch: true);
      } else {
        setState(() {
          _currentSettings.requestToReadTerms = true;
        });
      }
    } else {
      setState(() {
        _currentSettings.requestToReadTerms = false;
      });
    }
  }

  void _saveAndPop() {
    widget.onSave(_currentSettings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          widget.onSave(_currentSettings);
        }
      },
      child: Scaffold(
        appBar: MyAppBar(
          leading: BackButton(onPressed: _saveAndPop),
          title: widget.isNew ? 'Group Settings' : 'Edit Group Settings',
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SettingsSwitchListTile(
                  title: 'Request to read terms',
                  subtitle:
                      'Request new members to read the team\'s information before they can join',
                  icon: FontAwesomeIcons.readme,
                  containerColor: Colors.purple,
                  value: _currentSettings.requestToReadTerms,
                  onChanged: _handleRequestToReadChange,
                ),
                const SizedBox(height: 20),
                SettingsSwitchListTile(
                  title: 'Allow sharing',
                  subtitle:
                      'Allow members to share their generated DSTIs, RiskAssessments, and Tools with this organization',
                  icon: FontAwesomeIcons.share,
                  containerColor: Colors.blue,
                  value: _currentSettings.allowSharing,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.allowSharing = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SettingsSwitchListTile(
                  title: 'Allow creating',
                  subtitle:
                      'Allow members to create new DSTIs, RiskAssessments, and Tools',
                  icon: FontAwesomeIcons.key,
                  containerColor: Colors.green,
                  value: _currentSettings.allowCreate,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.allowCreate = value;
                    });
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 50,
                  child: MainAppButton(
                    label: ' Edit Terms and Conditions ',
                    borderRadius: 15.0,
                    onTap: () => _showTermsEditDialog(context),
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
