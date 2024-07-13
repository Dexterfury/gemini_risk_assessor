import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';

class OrgSettingsProvider extends ChangeNotifier {
  OrganizationModel? _organizationModel;

  OrganizationModel? get organizationModel => _organizationModel;

  final CollectionReference _organizationCollection =
      FirebaseFirestore.instance.collection(Constants.organizationCollection);

  // set OrganizationModel
  Future<void> setOrganizationModel(OrganizationModel organizationModel) async {
    _organizationModel = organizationModel;
    notifyListeners();
  }

  // setters
  Future<void> setRequestToReadTerms(bool value) async {
    _organizationModel!.requestToReadTerms = value; // Update the model as well
    notifyListeners();
    // updates requestToReadTerms in Firestore
    await _organizationCollection
        .doc(_organizationModel!.organizationID)
        .update({
      Constants.requestToReadTerms: value,
    });
  }

  Future<void> setAllowSharing(bool value) async {
    _organizationModel!.allowSharing = value; // Update the model as well
    notifyListeners(); // Notify listeners when the state
    // updates allowSharing in Firestore
    await _organizationCollection
        .doc(_organizationModel!.organizationID)
        .update({
      Constants.allowSharing: value,
    });
  }

  Future<void> setOrganizationTerms(String terms) async {
    _organizationModel!.organizationTerms = terms;
    notifyListeners();
    // updates organizationTerms in Firestore
    await _organizationCollection
        .doc(_organizationModel!.organizationID)
        .update({
      Constants.organizationTerms: terms,
    });
  }
}
