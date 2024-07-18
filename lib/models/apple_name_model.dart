class AppleNameModel {
  final String givenName;
  final String familyName;

  AppleNameModel({required this.givenName, required this.familyName});

  @override
  String toString() {
    return '$givenName $familyName';
  }
}
