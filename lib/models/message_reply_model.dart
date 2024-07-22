import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';

class MessageReplyModel {
  final String message;
  final String senderUID;
  final String senderName;
  final String senderImage;
  final MessageType messageType;
  final bool isMe;

  MessageReplyModel({
    required this.message,
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.messageType,
    required this.isMe,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.message: message,
      Constants.senderUID: senderUID,
      Constants.senderName: senderName,
      Constants.senderImage: senderImage,
      Constants.messageType: messageType.name,
      Constants.isMe: isMe,
    };
  }

  // from map
  factory MessageReplyModel.fromMap(Map<String, dynamic> map) {
    return MessageReplyModel(
      message: map[Constants.message] ?? '',
      senderUID: map[Constants.senderUID] ?? '',
      senderName: map[Constants.senderName] ?? '',
      senderImage: map[Constants.senderImage] ?? '',
      messageType: map[Constants.messageType].toString().toMessageType(),
      isMe: map[Constants.isMe] ?? false,
    );
  }
}
