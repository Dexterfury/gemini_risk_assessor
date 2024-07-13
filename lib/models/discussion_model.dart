class DiscussionModel {
  String id;
  String title;
  String description;
  String discussingAbout;
  String createdBy;
  String organizationID;
  String createdAt;

  // constructor
  DiscussionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discussingAbout,
    required this.createdBy,
    required this.organizationID,
    required this.createdAt,
  });
}
