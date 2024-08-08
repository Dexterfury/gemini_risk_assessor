import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/groups/groups_settings.dart';
import 'package:gemini_risk_assessor/screens/people_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_group_image.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _finalFileImage;
  DataSettings _dataSettings = DataSettings();

  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Create Group Screen',
      screenClass: 'CreateGroupScreen',
    );
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final count = groupProvider.awaitApprovalsList.length;
    final selectedCount = getFormatedCount(count);

    return Scaffold(
      appBar: MyAppBar(
        title: 'Create Group',
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: () => _navigateToGroupSettings(context),
            icon: const Icon(FontAwesomeIcons.gear),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupImageSection(context, selectedCount),
              const SizedBox(height: 24),
              _buildInputField(
                label: Constants.groupName,
                controller: _nameController,
                icon: Icons.group,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                  label: Constants.enterDescription,
                  controller: _descriptionController,
                  icon: Icons.description,
                  maxLines: 3,
                  maxLength: 800,
                  textInputAction: TextInputAction.done),
              const SizedBox(height: 32),
              _buildCreateButton(context, groupProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupImageSection(BuildContext context, String selectedCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: DisplayGroupImage(
              fileImage: _finalFileImage,
              onPressed: () => _pickImage(context),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            Text(selectedCount, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _navigateToPeopleScreen(context),
              icon: const Icon(FontAwesomeIcons.userPlus, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    int maxLength = 25,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCreateButton(
    BuildContext context,
    GroupProvider groupProvider,
  ) {
    return SizedBox(
        height: 50,
        width: double.infinity,
        child: MainAppButton(
          label: 'Create Group',
          onTap: () => _createGroup(context, groupProvider),
        ));
  }

  void _navigateToGroupSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupSettingsScreen(
          isNew: true,
          initialSettings: _dataSettings,
          onSave: (DataSettings settings) {
            setState(() => _dataSettings = settings);
          },
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final file =
        await ImagePickerHandler.showImagePickerDialog(context: context);
    if (file != null) {
      setState(() => _finalFileImage = file);
    }
  }

  void _navigateToPeopleScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PeopleScreen(userViewType: UserViewType.creator),
      ),
    );
  }

  void _createGroup(BuildContext context, GroupProvider groupProvider) async {
    if (groupProvider.isLoading) return;

    if (_nameController.text.isEmpty || _nameController.text.length < 3) {
      _showErrorSnackBar(context);
      return;
    }

    await AnalyticsHelper.logCustomEvent('create_group', parameters: {
      'group_name': _nameController.text,
    });

    final groupModel = GroupModel(
      creatorUID: context.read<AuthenticationProvider>().userModel!.uid,
      name: _nameController.text,
      aboutGroup: _descriptionController.text,
      groupID: '',
      groupTerms: _dataSettings.groupTerms,
      requestToReadTerms: _dataSettings.requestToReadTerms,
      allowSharing: _dataSettings.allowSharing,
      allowCreate: _dataSettings.allowCreate,
    );

    _showLoadingDialog(context);

    groupProvider.createGroup(
      fileImage: _finalFileImage,
      newgroupModel: groupModel,
      onSuccess: () => _handleCreateSuccess(context),
      onError: (error) => _handleCreateError(context, error),
    );
  }

  void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_nameController.text.isEmpty
            ? 'Please enter group name'
            : 'Group name must be at least 3 characters'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Creating group'),
        content: SizedBox(
          height: 100,
          width: 100,
          child: Center(child: LoadingPPEIcons()),
        ),
      ),
    );
  }

  void _handleCreateSuccess(BuildContext context) {
    Navigator.of(context).pop(); // Dismiss loading dialog
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _finalFileImage = null;
      _dataSettings = DataSettings();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group created successfully')),
    );
    Navigator.of(context).pop(); // Return to previous screen
  }

  void _handleCreateError(BuildContext context, String error) {
    Navigator.of(context).pop(); // Dismiss loading dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }
}
