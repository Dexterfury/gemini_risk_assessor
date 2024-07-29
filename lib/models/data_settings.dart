class DataSettings {
  bool requestToReadTerms;
  bool allowSharing;
  bool allowCreate;
  String groupTerms;

  // constructor
  DataSettings({
    this.requestToReadTerms = false,
    this.allowSharing = false,
    this.allowCreate = false,
    this.groupTerms = '',
  });
}
