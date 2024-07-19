import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/authentication/firebase_auth_error_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      // Check if the user can change their password
      if (!_canChangePassword(user)) {
        throw Exception(
            'Password change is not available for this account type.');
      }

      // Re-authenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);

      Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
        showSnackBar(
            context: context, message: 'Password updated successfully');
      });
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code} - ${e.message}');
      Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
        FirebaseAuthErrorHandler.showErrorSnackBar(context, e);
      });
    } catch (e) {
      log('error signing: ${e.toString()}');
      Future.delayed(const Duration(milliseconds: 200), () {
        showSnackBar(
            context: context, message: 'An unexpected error occurred: $e');
      });
    }
  }

  bool _canChangePassword(User user) {
    // Check if the user signed in with a method that supports password changes
    return user.providerData
        .any((userInfo) => userInfo.providerId == 'password');
  }
}
