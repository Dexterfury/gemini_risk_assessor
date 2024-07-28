import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';

class MyDialogs {
  // general dialog
  static void showMyAnimatedDialog({
    required BuildContext context,
    required String title,
    String content = '',
    Widget? loadingIndicator, // loading indicator
    Widget? signatureInput, // signature field
    List<Widget>? actions,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
              child: AlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                content: getContent(
                  content,
                  loadingIndicator,
                  signatureInput,
                ),
                actions: actions,
              ),
            ));
      },
    );
  }

  static void showMyDataDialog({
    required BuildContext context,
    required String title,
    required String content,
    List<Widget>? actions,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Text(content),
                ),
              ),
              actions: actions,
            ),
          ),
        );
      },
    );
  }

  static void showMyDiscussionsDialog({
    required BuildContext context,
    required String title,
    required Map<String, bool> results,
    required Function(String) tapAction,
  }) {
    showGeneralDialog(
      context: context,
      //barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
              child: AlertDialog(
                title: FittedBox(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (results[Constants.hasAssessments]!)
                      Card(
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.only(left: 8.0, right: 8.0),
                          title: const Text(Constants.riskAssessment),
                          leading: const Icon(Icons.assignment_late_outlined),
                          onTap: () {
                            Navigator.pop(context);
                            tapAction(Constants.riskAssessment);
                          },
                        ),
                      ),
                    if (results[Constants.hasDSTI]!)
                      Card(
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.only(left: 8.0, right: 8.0),
                          title:
                              const Text(Constants.dailySafetyTaskInstructions),
                          leading: const Icon(Icons.assignment_add),
                          onTap: () {
                            Navigator.pop(context);
                            tapAction(Constants.dailySafetyTaskInstructions);
                          },
                        ),
                      ),
                    if (results[Constants.hasTools]!)
                      Card(
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.only(left: 8.0, right: 8.0),
                          title: const Text(Constants.tools),
                          leading: const Icon(Icons.handyman),
                          onTap: () {
                            Navigator.pop(context);
                            tapAction(Constants.tools);
                          },
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ));
      },
    );
  }

  // termsdialog
  static void animatedTermsDialog({
    required BuildContext context,
    required String title,
    required String content,
    required bool isMember,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    bool isScrolledToBottom = false;
    late ScrollController scrollController;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        scrollController = ScrollController();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.position.maxScrollExtent == 0) {
            isScrolledToBottom = true;
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            scrollController.addListener(() {
              if (scrollController.offset >=
                      scrollController.position.maxScrollExtent &&
                  !scrollController.position.outOfRange) {
                setState(() {
                  isScrolledToBottom = true;
                });
              }
            });
            List<Widget> actions = isMember
                ? [
                    TextButton(
                      onPressed: onDecline,
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ]
                : [
                    TextButton(
                      onPressed: onDecline,
                      child: const Text(
                        'Decline',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: isScrolledToBottom ? onAccept : null,
                      child: const Text('Accept'),
                    ),
                  ];

            return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
              ),
              child: FadeTransition(
                opacity:
                    Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
                child: AlertDialog(
                  title: Text(
                    title,
                    textAlign: TextAlign.center,
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Scrollbar(
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: MarkdownBody(
                          selectable: true,
                          data: content,
                        ),
                      ),
                    ),
                  ),
                  actions: actions,
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void animatedEditTermsDialog({
    required BuildContext context,
    required String initialTerms,
    required Function(String) action,
  }) {
    final textController = TextEditingController(text: initialTerms);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation1, curve: Curves.easeOutBack)
              .drive(Tween<double>(begin: 0.5, end: 1.0)),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation1, curve: Curves.easeIn)
                .drive(Tween<double>(begin: 0.5, end: 1.0)),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Terms and Conditions',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: TextField(
                  controller: textController,
                  minLines: 1,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    labelText: 'Terms and conditions',
                    hintText: 'Enter terms and conditions',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                    filled: true,
                    //fillColor: Colors.grey[50],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    action(textController.text);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              backgroundColor: Theme.of(context).cardColor,
              elevation: 8,
            ),
          ),
        );
      },
    );
  }

// edit dialogs
  static void showMyEditAnimatedDialog({
    required BuildContext context,
    required String title,
    int maxLength = 20,
    String hintText = '',
    required String textAction,
    required Function(bool, String) onActionTap,
  }) {
    final controller = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation1, curve: Curves.easeOutBack)
              .drive(Tween<double>(begin: 0.5, end: 1.0)),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation1, curve: Curves.easeIn)
                .drive(Tween<double>(begin: 0.5, end: 1.0)),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: TextField(
                controller: controller,
                maxLength: maxLength,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: hintText,
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                  filled: true,
                  //fillColor: Colors.grey[50],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(false, controller.text);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(true, controller.text);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(textAction,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              backgroundColor: Theme.of(context).cardColor,
              elevation: 8,
            ),
          ),
        );
      },
    );
  }

  // people dialog
  // static void showAnimatedPeopleDialog({
  //   required BuildContext context,
  //   required UserViewType userViewType,
  //   List<Widget>? actions,
  // }) {
  //   showGeneralDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     barrierLabel: '',
  //     transitionDuration: const Duration(milliseconds: 200),
  //     pageBuilder: (context, animation1, animation2) {
  //       return Container();
  //     },
  //     transitionBuilder: (context, animation1, animation2, child) {
  //       return ScaleTransition(
  //           scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
  //           child: FadeTransition(
  //             opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
  //             child: AlertDialog(
  //               content: SizedBox(
  //                 height: MediaQuery.of(context).size.height * 0.6,
  //                 width: MediaQuery.of(context).size.width,
  //                 child: PeopleScreen(
  //                   userViewType: userViewType,
  //                 ),
  //               ),
  //               actions: actions ?? [],
  //             ),
  //           ));
  //     },
  //   );
  // }

  static getContent(
    String content,
    Widget? loadingIndicator,
    Widget? signatureInput,
  ) {
    if (loadingIndicator != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator,
        ],
      );
    } else if (signatureInput != null) {
      return signatureInput;
    } else {
      return Text(
        content,
        textAlign: TextAlign.center,
      );
    }
  }
}

class LoadingPPEIcons extends StatefulWidget {
  const LoadingPPEIcons({
    super.key,
  });

  @override
  State<LoadingPPEIcons> createState() => _LoadingPPEIconsState();
}

class _LoadingPPEIconsState extends State<LoadingPPEIcons> {
  late Timer _timer;
  int _currentIconIndex = 0;
  late List<PpeModel> _ppeIcons;

  @override
  void initState() {
    super.initState();
    _ppeIcons = Constants.getPPEIcons(radius: 30.0);
    _ppeIcons.removeLast(); // Remove the "Other" option
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIconIndex = Random().nextInt(_ppeIcons.length);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ppeIcons[_currentIconIndex].icon,
          const SizedBox(height: 8),
          Text(
            _ppeIcons[_currentIconIndex].label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
