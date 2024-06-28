import 'dart:io';

import 'package:flutter/foundation.dart';

class OrganisationProvider extends ChangeNotifier {
  bool _isLoading = false;
  File? _finalFileImage;

  // getters
  bool get isLoading => _isLoading;
  File? get finalFileImage => _finalFileImage;
}
