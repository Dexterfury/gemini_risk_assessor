import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isSuccessful = false;
  int? _resendToken;
  String? _uid;
  String? _phoneNumber;
  Timer? _timer;
  int _secondsRemaing = 60;

  File? _finalFileImage;
  String _userImage = '';

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
  int get secondsRemaing => _secondsRemaing;

  // setters

  // set loading
  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // set signed in
  void setIsSignedIn(bool value) {
    _isSignedIn = value;
    notifyListeners();
  }

  // check if user is signed in
  // static Future<bool> checkUserSignedIn() async {
  //   final User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     return true;
  //   }
  //   {
  //     return false;
  //   }
  // }

  // // save user to firestore
  // Future<void> saveUserToFirestore(UserModel user) async {
  //   try {
  //     await _usersCollection.doc(user.uid).set(user.toJson());
  //     // update name
  //     await _auth.currentUser!.updateDisplayName(user.name);
  //     // update photo url
  //     await _auth.currentUser!.updatePhotoURL(user.imageUrl);
  //   } on FirebaseException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //   }
  // }

  // // get user from firestore
  // static Future<UserModel> getUserDataFromFireStore(String uid) async {
  //   final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //       .collection(Constants.userCollection)
  //       .doc(uid)
  //       .get();
  //   return UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
  // }

  // // check if user exists in firestore
  // Future<bool> checkUserExistsInFirestore(String uid) async {
  //   try {
  //     final DocumentSnapshot documentSnapshot =
  //         await _usersCollection.doc(uid).get();
  //     if (documentSnapshot.exists) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } on FirebaseException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //     return false;
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //     return false;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //     return false;
  //   }
  // }

  // // save user data to shared preferences
  // Future<void> saveUserDataToSharedPreference(UserModel user) async {
  //   // save user data to shared preferences
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(Constants.userModel, jsonEncode(user.toJson()));
  // }

  // // get user from shared preferences
  // static Future<UserModel?> getUserDataFromSharedPrefences() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String userString = prefs.getString(Constants.userModel) ?? '';
  //   return UserModel.fromJson(jsonDecode(userString));
  // }

  // // sign in with google
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount =
  //         await GoogleSignIn().signIn();

  //     if (googleSignInAccount == null) {
  //       return null;
  //     }

  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );

  //     final UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);

  //     final User? user = userCredential.user;

  //     return user;
  //   } on FirebaseException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //     // set loading to false
  //     setIsLoading(false);
  //     return null;
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //     // set loading to false
  //     setIsLoading(false);
  //     return null;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //     // set loading to false
  //     setIsLoading(false);
  //     return null;
  //   }
  // }

  // // sign in user
  // Future<void> signInUser({
  //   required SignInType signInType,
  // }) async {
  //   try {
  //     // start loading
  //     setIsLoading(true);
  //     switch (signInType) {
  //       case SignInType.google:
  //         final User? user = await signInWithGoogle();
  //         if (user != null) {
  //           // check if user exists in firestore
  //           final bool userExistsInFirestore =
  //               await checkUserExistsInFirestore(user.uid);
  //           if (userExistsInFirestore) {
  //             // get user data from firestore
  //             _userModel = await getUserDataFromFireStore(user.uid);
  //             notifyListeners();
  //           } else {
  //             // create user model
  //             _userModel = UserModel(
  //               uid: user.uid,
  //               name: user.displayName ?? '',
  //               email: user.email ?? '',
  //               imageUrl: user.photoURL ?? '',
  //               levelPoints: 0.0,
  //               ctreatedAt: DateTime.now().toString(),
  //             );
  //             notifyListeners();
  //             // save user to firestore
  //             await saveUserToFirestore(_userModel!);
  //           }
  //           // save user data to shared preferences
  //           await saveUserDataToSharedPreference(_userModel!);
  //           // set signed in to true
  //           setIsSignedIn(true);
  //         }
  //         break;
  //       case SignInType.email:
  //         break;
  //       default:
  //         break;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //   } finally {
  //     setIsLoading(false);
  //   }
  // }

  // // sign out
  // Future<void> signOut() async {
  //   try {
  //     await _auth.signOut();
  //     // set signed in to false
  //     setIsSignedIn(false);
  //     // set user model to null
  //     _userModel = null;
  //     // remove user data from shared preferences
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.remove(Constants.userModel);
  //   } on FirebaseException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       log('Error occured: $e');
  //     }
  //   }
  // }
}
