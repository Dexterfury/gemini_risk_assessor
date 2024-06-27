import 'package:flutter/foundation.dart';

class OrganisationProvider extends ChangeNotifier {
  bool _isLoading = false;

  // getters
  bool get isLoading => _isLoading;
}
