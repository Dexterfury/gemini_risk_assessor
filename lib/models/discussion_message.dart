import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';

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
  final String repliedMessage;
  final String repliedTo;
  final MessageType repliedMessageType;
  final List<String> reactions;
  final List<String> seenBy;
  final List<String> deletedBy;

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
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.reactions,
    required this.seenBy,
    required this.deletedBy,
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
      Constants.repliedMessage: repliedMessage,
      Constants.repliedTo: repliedTo,
      Constants.repliedMessageType: repliedMessageType.name,
      Constants.reactions: reactions,
      Constants.seenBy: seenBy,
      Constants.deletedBy: deletedBy,
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
      repliedMessage: map[Constants.repliedMessage] ?? '',
      repliedTo: map[Constants.repliedTo] ?? '',
      repliedMessageType:
          map[Constants.repliedMessageType].toString().toMessageType(),
      reactions: List<String>.from(map[Constants.reactions] ?? []),
      seenBy: List<String>.from(map[Constants.seenBy] ?? []),
      deletedBy: List<String>.from(map[Constants.deletedBy] ?? []),
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
    String? repliedMessage,
    String? repliedTo,
    MessageType? repliedMessageType,
    List<String>? reactions,
    List<String>? seenBy,
    List<String>? deletedBy,
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
      repliedMessage: repliedMessage ?? this.repliedMessage,
      repliedTo: repliedTo ?? this.repliedTo,
      repliedMessageType: repliedMessageType ?? this.repliedMessageType,
      reactions: reactions ?? this.reactions,
      seenBy: seenBy ?? this.seenBy,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }
}
