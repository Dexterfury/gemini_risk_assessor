class DataSettings {
  bool requestToReadTerms;
  bool allowSharing;
  bool allowCreate;
  bool useSafetyFile;
  String safetyFileContent;
  String safetyFileUrl;
  String groupTerms;

  // constructor
  DataSettings({
    this.requestToReadTerms = false,
    this.allowSharing = false,
    this.allowCreate = false,
    this.useSafetyFile = false,
    this.safetyFileContent = '',
    this.safetyFileUrl = '',
    this.groupTerms = '',
  });
}
