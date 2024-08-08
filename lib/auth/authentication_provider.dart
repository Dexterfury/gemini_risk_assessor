import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/auth/user_information_screen.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/firebase/error_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utilities/file_upload_handler.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isSuccessful = false;
  int? _resendToken;
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

  Future<AuthStatus> checkAuthenticationState({
    required String? uid,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    if (uid != null) {
      //_uid = _auth.currentUser!.uid;

      // Check if user exists in Firestore
      if (await checkUserExistsInFirestore(uid: uid)) {
        // Get user data from Firestore
        await getUserDataFromFireStore();
        // Save user data to shared preferences
        await saveUserDataToSharedPreferences();
        notifyListeners();
        return AuthStatus.authenticated;
      } else {
        return AuthStatus.authenticatedButNoData;
      }
    } else {
      return AuthStatus.unauthenticated;
    }
  }

  // get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot = await _firestore
        .collection(Constants.usersCollection)
        .doc(_auth.currentUser!.uid)
        .get();
    _userModel =
        UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  // save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    // if is anonymous user, dont save to shared preferences
    if (_auth.currentUser!.isAnonymous) return;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toJson()));
  }

  // get data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    // if his anonymous user, dont get from shared preferences
    if (_auth.currentUser!.isAnonymous) return;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromJson(jsonDecode(userModelString));
    //_uid = _userModel!.uid;
    notifyListeners();
  }

  // save user data to firestore
  Future<void> saveUserDataToFireStore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
  }) async {
    if (fileImage != null) {
      // upload image to storage
      String imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
          file: fileImage,
          reference: '${Constants.userImages}/${userModel.uid}.jpg');

      userModel.imageUrl = imageUrl;
      // update the display image in firebase auth
      await _auth.currentUser!.updatePhotoURL(imageUrl);
    }
    userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

    _userModel = userModel;
    //_uid = userModel.uid;

    // save user data to firestore
    await _firestore
        .collection(Constants.usersCollection)
        .doc(userModel.uid)
        .set(userModel.toJson());

    onSuccess();
    notifyListeners();
  }

  // check if user exists in firestore
  Future<bool> checkUserExistsInFirestore({required String uid}) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _usersCollection.doc(uid).get();
      if (documentSnapshot.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e, stack) {
      ErrorHandler.recordError(
        e,
        stack,
        reason: 'Error checking user existence',
        severity: ErrorSeverity.critical,
      );
      return false;
    }
  }

  Future<UserCredential> linkAnonymousAccountWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || !currentUser.isAnonymous) {
      throw Exception('No anonymous user to link');
    }

    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    final userCredential = await currentUser.linkWithCredential(credential);

    // Update display name
    await userCredential.user!.updateDisplayName(name);

    return userCredential;
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
          //_uid = user.uid;
          _phoneNumber = user.phoneNumber;
          // update phone with firebase auth
          //await _auth.currentUser!.updatePhoneNumber(credential);
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
        try {
          userCredential = await currentUser.linkWithCredential(credential);
          // update phone with firebase auth
          await _auth.currentUser!.updatePhoneNumber(credential);
          wasAnonymouse = true;
        } on FirebaseAuthException catch (e, stack) {
          if (e.code == 'credential-already-in-use') {
            // If the credential is already associated with an account,
            // sign out the anonymous user and sign in with the credential
            await _auth.signOut();
            userCredential = await _auth.signInWithCredential(credential);
            // update phone with firebase auth
            await _auth.currentUser!.updatePhoneNumber(credential);
            wasAnonymouse = true;
          } else {
            ErrorHandler.recordError(e, stack, reason: 'Error signing in');
            throw e;
          }
        }
      } else {
        // If there's no current user or it's not anonymous, just sign in
        userCredential = await _auth.signInWithCredential(credential);
        wasAnonymouse = false;
      }

      //await _postSignInActions(context, userCredential.user!);
      return (userCredential.user, wasAnonymouse);
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error signing in');
      return (null, false);
    }
  }

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function(String) onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      final (User? user, bool wasAnonymous) =
          await _handlePhoneAuthCredential(credential, context);

      if (user != null) {
        _phoneNumber = user.phoneNumber;
        _isSuccessful = true;
        _isLoading = false;
        notifyListeners();
      }
      if (wasAnonymous) {
        _isLoading = false;
        notifyListeners();
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
      onSuccess(user!.uid);
    } catch (e) {
      _handleAuthError(e, context);
    }
  }

  void _handleVerificationFailed(
      FirebaseAuthException e, BuildContext context) {
    _isLoading = false;
    notifyListeners();
    // showSnackBar(context: context, message: e.toString());
    // log('Error: ${e.toString()}');
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

  // sign in user with email and password
  Future<UserCredential?> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    //_uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  // create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    //_uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  Future<UserCredential?> _signInWithGoogle({bool link = false}) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (link && isUserAnonymous() == true) {
        return await _auth.currentUser?.linkWithCredential(credential);
      } else {
        return await _auth.signInWithCredential(credential);
      }
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error in _signInWithGoogle');
      return null;
    }
  }

  Future<UserCredential?> _signInWithApple({bool link = false}) async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: 'com.raphaeldaka.geminiriskassessor.signin',
                redirectUri: Uri.parse(
                  'https://gemini-risk-assessor.firebaseapp.com/__/auth/handler',
                ),
              )
            : null,
      );
      final oAuthCredential = OAuthProvider('apple.com');
      final credential = oAuthCredential.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      UserCredential userCredential;
      if (link && isUserAnonymous() == true) {
        userCredential = await FirebaseAuth.instance.currentUser!
            .linkWithCredential(credential);
      } else {
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // Determine the display name
      String displayName;
      if (appleIdCredential.givenName != null &&
          appleIdCredential.familyName != null) {
        displayName =
            '${appleIdCredential.givenName} ${appleIdCredential.familyName}';
      } else {
        displayName = 'Apple User';
      }

      // Update the user's display name
      await userCredential.user?.updateDisplayName(displayName);

      // Fetch the user again to ensure we have the updated information
      await userCredential.user?.reload();

      return userCredential;
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error in _signInWithApple');
      setLoading(false);
      return null;
    }
  }

  // send verification email
  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  // reload firebase user
  Future<void> reloadUser() async {
    await _auth.currentUser!.reload();
  }

  // check email is verified
  Future<bool> isEmailVerified() async {
    return _auth.currentUser!.emailVerified;
  }

  // get user email
  Future<String> getUserEmail() async {
    return _auth.currentUser!.email!;
  }

  Future<UserCredential?> socialLogin({
    required BuildContext context,
    required SignInType signInType,
  }) async {
    bool isAnonymous = isUserAnonymous();
    UserCredential? userCredential;

    switch (signInType) {
      case SignInType.google:
        userCredential = await _signInWithGoogle(link: isAnonymous);
        break;
      case SignInType.apple:
        userCredential = await _signInWithApple(link: isAnonymous);
        break;
      case SignInType.anonymous:
        userCredential = await _auth.signInAnonymously();
        isAnonymous = true;
        notifyListeners();
        break;
      default:
        throw Exception('Invalid sign-in type');
    }

    return userCredential;
  }

  Future<void> createAndSaveNewUser(User user, bool wasAnonymous) async {
    _userModel = UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      phone: user.phoneNumber ?? '',
      email: user.email ?? '',
      imageUrl: user.photoURL ?? '',
      token: '',
      aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
      rating: 0,
      safetyPoints: 0,
      isAnonymous: wasAnonymous,
      createdAt: DateTime.now().toIso8601String(),
    );
    await saveUserDataToFireStore(
      userModel: _userModel!,
      fileImage: null,
      onSuccess: () async {
        await saveUserDataToSharedPreferences();
      },
    );
  }

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
      await FirebaseMethods.updateGroupName(id, newName);
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
      await FirebaseMethods.updateGroupDesc(id, newDesc);
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

  // update the group image
  Future<void> setImageUrl(String imageUrl) async {
    _userModel!.imageUrl = imageUrl;
    notifyListeners();
  }

  // up date the group name
  Future<void> setName(String name) async {
    _userModel!.name = name;
    notifyListeners();
  }

  // up date the group description
  Future<void> setDescription(String description) async {
    _userModel!.aboutMe = description;
    notifyListeners();
  }

  static Future<void> sendPasswordResetEmail({
    required String email,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      onSuccess();
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack,
          reason: 'Error during sending password reset email');
      onError(e.toString());
    }
  }

  static Future<bool> checkOldPassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    AuthCredential authCredential =
        EmailAuthProvider.credential(email: email, password: password);

    try {
      var credentialResult = await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(authCredential);

      return credentialResult.user != null;
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error during password check');
      // We show snackBar to our user
      await showSnackBar(
        context: context,
        message: 'Error during updating password, please try again later',
      );
      return false;
    }
  }

  static Future<bool> updateUserPassword({
    required BuildContext context,
    required String newPassword,
  }) async {
    User user = FirebaseAuth.instance.currentUser!;

    try {
      await user.updatePassword(newPassword);
      return true;
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack,
          reason: 'Error during password change');
      // We show snackBar to our user
      await showSnackBar(
        context: context,
        message: 'Error during updating password, please try again later',
      );
      return false;
    }
  }

  // sign out
  Future<void> signOut({required BuildContext context}) async {
    try {
      // clear user token from firestore
      await _usersCollection.doc(_userModel!.uid).update({
        Constants.token: '',
      });
      await _auth.signOut();
      // set signed in to false
      setIsSignedIn(false);
      // set user model to null
      _userModel = null;
      // remove user data from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.userModel);
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error during sign out');
      // We show snackBar to our user
      await showSnackBar(
        context: context,
        message:
            'We encountered an issue while signing you out. Please try again later. If the problem persists, please contact support.',
      );
    }
  }

  // generate a new token
  Future<void> generateNewToken() async {
    if (_auth.currentUser != null) {
      try {
        final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
        String? token = await firebaseMessaging.getToken();

        // save token to firestore for authenticated users, not anonymous users
        if (!_userModel!.isAnonymous) {
          _usersCollection.doc(_userModel!.uid).update({
            Constants.token: token,
          });
        }
      } catch (e, stack) {
        ErrorHandler.recordError(e, stack,
            reason: 'FCM TOKEN GENERATION ERROR');
      }
    }
  }
}
