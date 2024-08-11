import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/settings_list_tile.dart';
import 'package:gemini_risk_assessor/widgets/settings_switch_list_tile.dart';

class GroupSettingsScreen extends StatefulWidget {
  final bool isNew;
  final DataSettings initialSettings;
  final Function(DataSettings) onSave;
  final String groupID;

  const GroupSettingsScreen({
    super.key,
    required this.isNew,
    required this.initialSettings,
    required this.onSave,
    this.groupID = '',
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
      useSafetyFile: widget.initialSettings.useSafetyFile,
      safetyFileContent: widget.initialSettings.safetyFileContent,
      safetyFileUrl: widget.initialSettings.safetyFileUrl,
      groupTerms: widget.initialSettings.groupTerms,
    );
  }

  void _showTermsEditDialog(BuildContext context, {bool fromSwitch = false}) {
    MyDialogs.animatedEditTermsDialog(
      context: context,
      initialTerms: _currentSettings.groupTerms,
      action: (String newTerms) {
        if (newTerms.length < 10) {
          showSnackBar(
            context: context,
            message: 'Terms must be at least 10 characters long.',
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

  void _showFilePicker(BuildContext context, {bool fromSwitch = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      try {
        MyDialogs.showMyAnimatedDialog(
          context: context,
          title: 'Uploading Safety File',
          loadingIndicator:
              const SizedBox(height: 100, width: 100, child: LoadingPPEIcons()),
        );
        final (String safetyFileUrl, String safetyFileContent) =
            await FileUploadHandler.uploadSafetyFile(
          context: context,
          file: file,
          collectionID: widget.groupID,
        );

        Navigator.pop(context);

        if (safetyFileUrl.isNotEmpty) {
          await FirebaseMethods.saveSafetyFile(
            collectionID: widget.groupID,
            isUser: false,
            safetyFileUrl: safetyFileUrl,
            safetyFileContent: safetyFileContent,
          ).whenComplete(() {
            showSnackBar(
                context: context, message: 'Safety file uploaded successfully');
            setState(() {
              _currentSettings.safetyFileContent = safetyFileContent;
              _currentSettings.safetyFileUrl = safetyFileUrl;
              if (fromSwitch) {
                _currentSettings.useSafetyFile = true;
                FirebaseMethods.ToggleUseSafetyFileInFirestore(
                  collectionID: widget.groupID,
                  isUser: false,
                  value: true,
                );
              }
            });
          });
        } else {
          setState(() {
            if (fromSwitch) {
              _currentSettings.useSafetyFile = false;
              FirebaseMethods.ToggleUseSafetyFileInFirestore(
                collectionID: widget.groupID,
                isUser: false,
                value: false,
              );
            }
          });
        }
      } catch (e) {
        Navigator.pop(context);
        showSnackBar(
            context: context, message: 'Error uploading file: ${e.toString()}');
      }
    }
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

  void _handleUseSafetyFile(bool value) {
    if (value) {
      if (_currentSettings.safetyFileContent.length < 1000) {
        // open file picker
        _showFilePicker(context, fromSwitch: value);
      } else {
        setState(() {
          _currentSettings.useSafetyFile = true;
        });
        FirebaseMethods.ToggleUseSafetyFileInFirestore(
          collectionID: widget.groupID,
          isUser: false,
          value: true,
        );
      }
    } else {
      setState(() {
        _currentSettings.useSafetyFile = false;
      });
      FirebaseMethods.ToggleUseSafetyFileInFirestore(
        collectionID: widget.groupID,
        isUser: false,
        value: false,
      );
    }
  }

  void _saveAndPop() {
    widget.onSave(_currentSettings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final termsBtnTitle = _currentSettings.groupTerms.length < 10
        ? ' Add Group Terms '
        : ' Edit Terms and Conditions ';
    final safetyBtnTitle = _currentSettings.safetyFileContent.length < 1000
        ? ' Add Safety File '
        : ' Udate Safety File ';
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'General Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),
                SettingsSwitchListTile(
                  title: 'Request to read terms',
                  subtitle:
                      'New members must read team information before joining',
                  icon: FontAwesomeIcons.readme,
                  containerColor: Colors.purple,
                  value: _currentSettings.requestToReadTerms,
                  onChanged: _handleRequestToReadChange,
                ),
                SettingsSwitchListTile(
                  title: 'Allow sharing',
                  subtitle:
                      'Members can share generated content with this group',
                  icon: FontAwesomeIcons.share,
                  containerColor: Colors.blue,
                  value: _currentSettings.allowSharing,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.allowSharing = value;
                    });
                  },
                ),
                SettingsSwitchListTile(
                  title: 'Allow creating',
                  subtitle: 'Members can create new content',
                  icon: FontAwesomeIcons.plus,
                  containerColor: Colors.green,
                  value: _currentSettings.allowCreate,
                  onChanged: (value) {
                    setState(() {
                      _currentSettings.allowCreate = value;
                    });
                  },
                ),
                if (widget.groupID.isNotEmpty)
                  SettingsSwitchListTile(
                    title: 'Enable Group Safety Protocol',
                    subtitle:
                        'Apply custom safety guidelines to AI-generated content',
                    icon: FontAwesomeIcons.shieldHalved,
                    containerColor: Colors.orange,
                    value: _currentSettings.useSafetyFile,
                    onChanged: _handleUseSafetyFile,
                  ),
                SizedBox(height: 32),
                Text(
                  'Additional Actions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),
                Card(
                  child: SettingsListTile(
                    title: termsBtnTitle,
                    icon: FontAwesomeIcons.fileContract,
                    onTap: () => _showTermsEditDialog(context),
                  ),
                ),
                // MainAppButton(
                //   label: termsBtnTitle,
                //   icon: FontAwesomeIcons.fileContract,
                //   onTap: () => _showTermsEditDialog(context),
                // ),
                SizedBox(height: 16),

                if (widget.groupID.isNotEmpty)
                  Card(
                    child: SettingsListTile(
                      title: safetyBtnTitle,
                      icon: FontAwesomeIcons.fileShield,
                      onTap: () => _showFilePicker(context),
                    ),
                  ),
                // MainAppButton(
                //   label: safetyBtnTitle,
                //   icon: FontAwesomeIcons.fileShield,
                //   onTap: () => _showFilePicker(context),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
