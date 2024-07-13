import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/providers/org_settings_provider.dart';
import 'package:gemini_risk_assessor/widgets/settings_switch_list_tile.dart';
import 'package:provider/provider.dart';

class OrganizationSettingsScreen extends StatefulWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  State<OrganizationSettingsScreen> createState() =>
      _OrganizationSettingsScreenState();
}

class _OrganizationSettingsScreenState
    extends State<OrganizationSettingsScreen> {
  void _showTermsEditDialog(
      BuildContext context, OrgSettingsProvider settingsProvider) {
    MyDialogs.animatedEditTermsDialog(
      context: context,
      initialTerms: settingsProvider.organizationModel!.organizationTerms,
      onSave: (String newTerms) async {
        await settingsProvider.setOrganizationTerms(newTerms);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Organization Settings',
      ),
      body: Consumer<OrgSettingsProvider>(
        builder: (context, settingProvider, child) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Column(
              children: [
                SettingsSwitchListTile(
                  title: 'Request to read teams',
                  subtitle:
                      'Request new members to read the team\'s information, before they can join',
                  icon: FontAwesomeIcons.personCirclePlus,
                  containerColor: Colors.green,
                  value: settingProvider.organizationModel!.requestToReadTerms,
                  onChanged: (value) async {
                    if (settingProvider
                        .organizationModel!.organizationTerms.isEmpty) {
                      // show dialog to add organization terms first
                      _showTermsEditDialog(context, settingProvider);
                    }
                    await settingProvider.setRequestToReadTerms(value);
                  },
                ),
                const SizedBox(height: 20),
                SettingsSwitchListTile(
                  title: 'Allow sharing',
                  subtitle:
                      'Allow members to share their generated, DSTIs, RiskAssessment, and Tools with this organization',
                  icon: FontAwesomeIcons.share,
                  containerColor: Colors.blue,
                  value: settingProvider.organizationModel!.allowSharing,
                  onChanged: (value) async {
                    await settingProvider.setAllowSharing(value);
                  },
                ),
                const SizedBox(height: 40),
                MainAppButton(
                  label: ' Edit Terms and Conditions ',
                  borderRadius: 15.0,
                  onTap: () => _showTermsEditDialog(context, settingProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
