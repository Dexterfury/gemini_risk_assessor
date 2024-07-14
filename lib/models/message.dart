import 'package:gemini_risk_assessor/constants.dart';

class Message {
  String senderID;
  String messageID;
  String chatID;
  String question;
  StringBuffer answer;
  List<String> imagesUrls;
  List<String> reactions;
  List<dynamic> sentencesUrls;
  bool finalWords;
  DateTime timeSent;

  // constructor
  Message({
    required this.senderID,
    required this.messageID,
    required this.chatID,
    required this.question,
    required this.answer,
    required this.imagesUrls,
    required this.reactions,
    required this.sentencesUrls,
    required this.finalWords,
    required this.timeSent,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      Constants.senderID: senderID,
      Constants.messageID: messageID,
      Constants.chatID: chatID,
      Constants.question: question,
      Constants.answer: answer.toString(),
      Constants.imagesUrls: imagesUrls,
      Constants.reactions: reactions,
      Constants.sentencesUrls: sentencesUrls,
      Constants.finalWords: finalWords,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
    };
  }

  // from json
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderID: json[Constants.senderID] ?? '',
      messageID: json[Constants.messageID] ?? '',
      chatID: json[Constants.chatID] ?? '',
      question: json[Constants.question] ?? '',
      answer: StringBuffer(json[Constants.answer] ?? ''),
      imagesUrls: List<String>.from(json[Constants.imagesUrls] ?? []),
      reactions: List<String>.from(json[Constants.reactions] ?? []),
      sentencesUrls: List<String>.from(json[Constants.sentencesUrls] ?? []),
      finalWords: json[Constants.finalWords] ?? true,
      timeSent: DateTime.fromMillisecondsSinceEpoch(json[Constants.timeSent]),
    );
  }

  // copyWith
  Message copyWith({
    String? senderID,
    String? messageID,
    String? chatID,
    String? question,
    StringBuffer? answer,
    List<String>? imagesUrls,
    List<String>? reactions,
    List<dynamic>? sentencesUrls,
    bool? finalWords,
    DateTime? timeSent,
  }) {
    return Message(
      senderID: senderID ?? this.senderID,
      messageID: messageID ?? this.messageID,
      chatID: chatID ?? this.chatID,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      reactions: reactions ?? this.reactions,
      sentencesUrls: sentencesUrls ?? this.sentencesUrls,
      finalWords: finalWords ?? this.finalWords,
      timeSent: timeSent ?? this.timeSent,
    );
  }
}
