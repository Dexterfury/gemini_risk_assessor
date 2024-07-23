class DataSettings {
  bool requestToReadTerms;
  bool allowSharing;
  String groupTerms;

  // constructor
  DataSettings({
    this.requestToReadTerms = false,
    this.allowSharing = false,
    this.groupTerms = '',
  });
}
