import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';

class MessageReply {
  final String message;
  final String senderUID;
  final String senderName;
  final String senderImage;
  final MessageType messageType;

  MessageReply({
    required this.message,
    required this.senderUID,
    required this.senderName,
    required this.senderImage,
    required this.messageType,
  });

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.message: message,
      Constants.senderUID: senderUID,
      Constants.senderName: senderName,
      Constants.senderImage: senderImage,
      Constants.messageType: messageType.name,
    };
  }

  // from map
  factory MessageReply.fromMap(Map<String, dynamic> map) {
    return MessageReply(
      message: map[Constants.message] ?? '',
      senderUID: map[Constants.senderUID] ?? '',
      senderName: map[Constants.senderName] ?? '',
      senderImage: map[Constants.senderImage] ?? '',
      messageType: map[Constants.messageType].toString().toMessageType(),
    );
  }

  // empty message reply
  static MessageReply get empty => MessageReply(
        message: '',
        senderUID: '',
        senderName: '',
        senderImage: '',
        messageType: MessageType.text,
      );
}
