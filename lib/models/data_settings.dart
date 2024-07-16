class DataSettings {
  bool requestToReadTerms;
  bool allowSharing;
  String organizationTerms;

  // constructor
  DataSettings({
    this.requestToReadTerms = false,
    this.allowSharing = false,
    this.organizationTerms = '',
  });
}
