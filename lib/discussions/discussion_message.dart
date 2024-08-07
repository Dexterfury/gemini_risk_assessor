import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/discussions/additional_data_model.dart';
import 'package:gemini_risk_assessor/discussions/quiz_model.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/message_reply_model.dart';

class DiscussionMessage {
  final String senderUID;
  final String senderName;
  final String senderImage;
  final String groupID;
  final String message;
  final MessageType messageType;
  final DateTime timeSent;
  final String messageID;
  final bool isSeen;
  final bool isAIMessage;
  final MessageReply repliedMessage;
  final List<String> reactions;
  final List<String> seenBy;
  final List<String> deletedBy;
  final AdditionalDataModel additionalData;
  final QuizModel quizData;
  final Map<String, dynamic> quizResults;

  DiscussionMessage({
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.groupID,
    required this.message,
    required this.messageType,
    required this.timeSent,
    required this.messageID,
    required this.isSeen,
    required this.isAIMessage,
    required this.repliedMessage,
    required this.reactions,
    required this.seenBy,
    required this.deletedBy,
    required this.additionalData,
    required this.quizData,
    required this.quizResults,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.senderUID: senderUID,
      Constants.senderName: senderName,
      Constants.senderImage: senderImage,
      Constants.groupID: groupID,
      Constants.message: message,
      Constants.messageType: messageType.name,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
      Constants.messageID: messageID,
      Constants.isSeen: isSeen,
      Constants.isAIMessage: isAIMessage,
      Constants.repliedMessage: repliedMessage.toMap(),
      Constants.reactions: reactions,
      Constants.seenBy: seenBy,
      Constants.deletedBy: deletedBy,
      Constants.additionalData: additionalData.toJson(),
      Constants.quizData: quizData.toJson(),
      Constants.quizResults: quizResults,
    };
  }

  // from map
  factory DiscussionMessage.fromMap(Map<String, dynamic> map) {
    return DiscussionMessage(
      senderUID: map[Constants.senderUID] ?? '',
      senderName: map[Constants.senderName] ?? '',
      senderImage: map[Constants.senderImage] ?? '',
      groupID: map[Constants.groupID] ?? '',
      message: map[Constants.message] ?? '',
      messageType: map[Constants.messageType].toString().toMessageType(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map[Constants.timeSent]),
      messageID: map[Constants.messageID] ?? '',
      isSeen: map[Constants.isSeen] ?? false,
      isAIMessage: map[Constants.isAIMessage] ?? false,
      repliedMessage: MessageReply.fromMap(map[Constants.repliedMessage] ?? {}),
      reactions: List<String>.from(map[Constants.reactions] ?? []),
      seenBy: List<String>.from(map[Constants.seenBy] ?? []),
      deletedBy: List<String>.from(map[Constants.deletedBy] ?? []),
      additionalData:
          AdditionalDataModel.fromJson(map[Constants.additionalData] ?? {}),
      quizData: QuizModel.fromJson(map[Constants.quizData] ?? {}),
      quizResults: Map<String, dynamic>.from(map[Constants.quizResults] ?? {}),
    );
  }

  // copy with
  DiscussionMessage copyWith({
    String? senderUID,
    String? senderName,
    String? senderImage,
    String? groupID,
    String? message,
    MessageType? messageType,
    DateTime? timeSent,
    String? messageID,
    bool? isSeen,
    bool? isAIMessage,
    MessageReply? repliedMessage,
    List<String>? reactions,
    List<String>? seenBy,
    List<String>? deletedBy,
    AdditionalDataModel? additionalData,
    QuizModel? quizData,
    Map<String, dynamic>? quizResults,
  }) {
    return DiscussionMessage(
      senderUID: senderUID ?? this.senderUID,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      groupID: groupID ?? this.groupID,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      timeSent: timeSent ?? this.timeSent,
      messageID: messageID ?? this.messageID,
      isSeen: isSeen ?? this.isSeen,
      isAIMessage: isAIMessage ?? this.isAIMessage,
      repliedMessage: repliedMessage ?? this.repliedMessage,
      reactions: reactions ?? this.reactions,
      seenBy: seenBy ?? this.seenBy,
      deletedBy: deletedBy ?? this.deletedBy,
      additionalData: additionalData ?? this.additionalData,
      quizData: quizData ?? this.quizData,
      quizResults: quizResults ?? this.quizResults,
    );
  }
}
