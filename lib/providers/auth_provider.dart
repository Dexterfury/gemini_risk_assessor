import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemini_risk_assessor/authentication/user_information_screen.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/file_upload_handler.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isSuccessful = false;
  int? _resendToken;
  String? _uid;
  String? _phoneNumber;
  Timer? _timer;
  int _secondsRemaining = 60;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);

  // getters
  bool get isSignedIn => _isSignedIn;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  int? get resendToken => _resendToken;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  Timer? get timer => _timer;
  int get secondsRemaining => _secondsRemaining;
  // setters

  // set loading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // set signed in
  void setIsSignedIn(bool value) {
    _isSignedIn = value;
    notifyListeners();
  }

  // check authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      // get user data from firestore
      await getUserDataFromFireStore();

      // save user data to shared preferences
      await saveUserDataToSharedPreferences();

      notifyListeners();

      isSignedIn = true;
    } else {
      isSignedIn = false;
    }

    return isSignedIn;
  }

  // get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.usersCollection).doc(_uid).get();
    _userModel =
        UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  // save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isLoading = true;
    notifyListeners();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toJson()));
  }

  // get data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromJson(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  // save user data to firestore
  Future<void> saveUserDataToFireStore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (fileImage != null) {
        // upload image to storage
        String imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
            file: fileImage,
            reference: '${Constants.userImages}/${userModel.uid}.jpg');

        userModel.imageUrl = imageUrl;
      }
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      // save user data to firestore
      await _firestore
          .collection(Constants.usersCollection)
          .doc(userModel.uid)
          .set(userModel.toJson());

      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  // check if user exists in firestore
  Future<bool> checkUserExistsInFirestore() async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _usersCollection.doc(_uid).get();
      if (documentSnapshot.exists) {
        return true;
      } else {
        return false;
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        log('Error occured: $e');
      }
      return false;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        log('Error occured: $e');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        log('Error occured: $e');
      }
      return false;
    }
  }

  // sign in anonymous
  Future<void> signInAnonymously({
    required Function() onSuccess,
    required Function(String) onFail,
  }) async {
    _isLoading = true;
    _isSuccessful = false;
    notifyListeners();
    try {
      // check if user is already signed in and sign them out first
      if (_auth.currentUser != null) {
        _uid = _auth.currentUser!.uid;
        notifyListeners();
        onSuccess();
        return;
      }

      await FirebaseAuth.instance.signInAnonymously().then((value) async {
        _uid = value.user!.uid;
        _phoneNumber = value.user!.phoneNumber;
        onSuccess();
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          _isLoading = false;
          notifyListeners();
          onFail(e.code);
          break;
        default:
          _isLoading = false;
          notifyListeners();
          onFail(e.code);
      }
    } finally {
      _isSuccessful = true;
      notifyListeners();
    }
  }

  // check if signed in user is anonymous or not
  bool isUserAnonymous() {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.isAnonymous;
    }
    return false;
  }

  // sign in with phone number
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final (User? user, bool wasAnonymous) =
            await _handlePhoneAuthCredential(
          credential,
          context,
        );
        if (user != null) {
          _uid = user.uid;
          _phoneNumber = user.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        _handleVerificationFailed(e, context);
      },
      codeSent: (String verificationId, int? resendToken) async {
        _handleCodeSent(
            verificationId, resendToken, phoneNumber, context, onSuccess);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
    );
  }

  Future<(User?, bool)> _handlePhoneAuthCredential(
    PhoneAuthCredential credential,
    BuildContext context,
  ) async {
    try {
      User? currentUser = _auth.currentUser;
      UserCredential userCredential;
      bool wasAnonymouse = false;

      if (currentUser != null && currentUser.isAnonymous) {
        // If current user is anonymous, try to link the credential
        log('is anonymouse');
        try {
          userCredential = await currentUser.linkWithCredential(credential);
          wasAnonymouse = true;
        } on FirebaseAuthException catch (e) {
          log('sign out: ${e.code}');
          if (e.code == 'credential-already-in-use') {
            // If the credential is already associated with an account,
            // sign out the anonymous user and sign in with the credential
            await _auth.signOut();
            userCredential = await _auth.signInWithCredential(credential);
            wasAnonymouse = true;
          } else {
            log('ERROR: $e');
            throw e;
          }
        }
      } else {
        log('HERE GOOD');
        // If there's no current user or it's not anonymous, just sign in
        userCredential = await _auth.signInWithCredential(credential);
        wasAnonymouse = false;
      }

      //await _postSignInActions(context, userCredential.user!);
      return (userCredential.user, wasAnonymouse);
    } catch (e) {
      return (null, false);
      //_handleAuthError(e, context);
    }
  }

  // Future<void> _postSignInActions(BuildContext context, User user) async {
  //   _uid = user.uid;
  //   _phoneNumber = user.phoneNumber;
  //   _isSuccessful = true;
  //   _isLoading = false;
  //   notifyListeners();

  //   bool userExists = await checkUserExistsInFirestore(user.uid);
  //   if (userExists) {
  //     await getUserDataFromFireStore(user.uid);
  //     await saveUserDataToSharedPreferences();
  //     navigationController(
  //         context: context, route: Constants.screensControllerRoute);
  //   } else {
  //     // If the user doesn't exist in Firestore, we need to save their data
  //     UserModel userModel = UserModel(
  //       uid: user.uid,
  //       name: user.displayName ??
  //           "User${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}",
  //       phone: user.phoneNumber ?? '',
  //       imageUrl: user.photoURL ?? '',
  //       token: '',
  //       aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
  //       createdAt: DateTime.now().toIso8601String(),
  //     );
  //     await saveUserDataToFireStore(userModel: userModel);
  //     await saveUserDataToSharedPreferences();
  //     navigationController(
  //         context: context, route: Constants.screensControllerRoute);
  //   }
  // }

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      final (User? user, bool wasAnonymous) =
          await _handlePhoneAuthCredential(credential, context);

      if (user != null) {
        _uid = user.uid;
        _phoneNumber = user.phoneNumber;
        _isSuccessful = true;
        _isLoading = false;
        notifyListeners();
      }
      if (wasAnonymous) {
        // if user was anonymouse, navigate to user information screen
        await Future.delayed(const Duration(milliseconds: 200))
            .whenComplete(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserInformationScreen(
                uid: user!.uid,
              ),
            ),
          );
        });
        return;
      }
      onSuccess();
    } catch (e) {
      _handleAuthError(e, context);
    }
  }

  void _handleVerificationFailed(
      FirebaseAuthException e, BuildContext context) {
    _isSuccessful = false;
    _isLoading = false;
    notifyListeners();
    showSnackBar(context: context, message: e.toString());
    log('Error: ${e.toString()}');
  }

  void _handleCodeSent(
    String verificationId,
    int? resendToken,
    String phoneNumber,
    BuildContext context,
    Function() onSuccess,
  ) {
    _isLoading = false;
    _resendToken = resendToken;
    _secondsRemaining = 60;
    _startTimer();
    notifyListeners();
    onSuccess();

    Future.delayed(const Duration(seconds: 1)).whenComplete(() {
      Navigator.of(context).pushNamed(
        Constants.optRoute,
        arguments: {
          Constants.verificationId: verificationId,
          Constants.phoneNumber: phoneNumber,
        },
      );
    });
  }

  void _handleAuthError(dynamic error, BuildContext context) {
    _isSuccessful = false;
    _isLoading = false;
    notifyListeners();
    showSnackBar(context: context, message: error.toString());
    log('Error: ${error.toString()}');
  }

  void _startTimer() {
    // cancel timer if any exist
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        // cancel timer
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  // dispose timer
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // resend code
  Future<void> resendCode({
    required BuildContext context,
    required String phone,
  }) async {
    if (_secondsRemaining == 0 || _resendToken != null) {
      // allow user to resend code only if timer is not running and resend token exists
      _isLoading = true;
      notifyListeners();
      _isLoading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) async {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isSuccessful = true;
            _isLoading = false;
            notifyListeners();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          showSnackBar(context: context, message: e.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          _isLoading = false;
          _resendToken = resendToken;
          notifyListeners();
          showSnackBar(context: context, message: 'Successful sent code');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
      );
    } else {
      showSnackBar(
          context: context,
          message: 'Please wait $_secondsRemaining seconds to resend');
    }
  }

  // verify otp code
  // Future<void> verifyOTPCode({
  //   required String verificationId,
  //   required String otpCode,
  //   required BuildContext context,
  //   required Function onSuccess,
  // }) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   final credential = PhoneAuthProvider.credential(
  //     verificationId: verificationId,
  //     smsCode: otpCode,
  //   );

  //   await _auth.signInWithCredential(credential).then((value) async {
  //     _uid = value.user!.uid;
  //     _phoneNumber = value.user!.phoneNumber;
  //     _isSuccessful = true;
  //     _isLoading = false;
  //     onSuccess();
  //     notifyListeners();
  //   }).catchError((e) {
  //     _isSuccessful = false;
  //     _isLoading = false;
  //     notifyListeners();
  //     showSnackBar(context: context, message: e.toString());
  //   });
  // }

  // update name
  Future<String> updateName({
    required bool isUser,
    required String id,
    required String newName,
    required String oldName,
  }) async {
    if (newName.isEmpty || newName.length < 3 || newName == oldName) {
      return 'Invalid name.';
    }

    if (!isUser) {
      await FirebaseMethods.updateOrgName(id, newName);
      final nameToReturn = newName;
      newName = '';
      return nameToReturn;
    } else {
      await FirebaseMethods.updateUserName(id, newName);

      _userModel!.name = newName;
      // save user data to share preferences
      await saveUserDataToSharedPreferences();
      newName = '';
      notifyListeners();
      return _userModel!.name;
    }
  }

  // update description
  Future<String> updateDescription({
    required bool isUser,
    required String id,
    required String newDesc,
    required String oldDesc,
  }) async {
    if (newDesc.isEmpty || newDesc.length < 3 || newDesc == oldDesc) {
      return 'Invalid description.';
    }

    if (!isUser) {
      await FirebaseMethods.updateOrgDesc(id, newDesc);
      final descToReturn = newDesc;
      newDesc = '';
      return descToReturn;
    } else {
      await FirebaseMethods.updateAboutMe(id, newDesc);

      _userModel!.aboutMe = newDesc;
      // save user data to share preferences
      await saveUserDataToSharedPreferences();
      newDesc = '';
      notifyListeners();
      return _userModel!.aboutMe;
    }
  }

  // update the organization image
  Future<void> setImageUrl(String imageUrl) async {
    _userModel!.imageUrl = imageUrl;
    notifyListeners();
  }

  // up date the organization name
  Future<void> setName(String name) async {
    _userModel!.name = name;
    notifyListeners();
  }

  // up date the organization description
  Future<void> setDescription(String description) async {
    _userModel!.aboutMe = description;
    notifyListeners();
  }

  // sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // set signed in to false
      setIsSignedIn(false);
      // set user model to null
      _userModel = null;
      // remove user data from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.userModel);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        log('Error occured: $e');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        log('Error occured: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error occured: $e');
      }
    }
  }

  // generate a new token
  Future<void> generateNewToken() async {
    if (_auth.currentUser != null) {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      String? token = await firebaseMessaging.getToken();

      log('Token: $token');

      // save token to firestore
      _usersCollection.doc(_userModel!.uid).update({
        Constants.token: token,
      });
    }
  }
}
