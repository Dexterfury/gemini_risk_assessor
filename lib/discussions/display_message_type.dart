import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/audio_player_widget.dart';
import 'package:gemini_risk_assessor/discussions/video_player_widget.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';

class DisplayMessageType extends StatelessWidget {
  const DisplayMessageType({
    super.key,
    required this.message,
    required this.type,
    required this.color,
    required this.isReply,
    this.maxLines,
    this.overFlow,
    required this.viewOnly,
  });

  final String message;
  final MessageType type;
  final Color color;
  final bool isReply;
  final int? maxLines;
  final TextOverflow? overFlow;
  final bool viewOnly;

  @override
  Widget build(BuildContext context) {
    return _buildMessageContent();
  }

  Widget _buildMessageContent() {
    switch (type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.video:
        return _buildVideoMessage();
      case MessageType.audio:
        return _buildAudioMessage();
      default:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message,
      style: TextStyle(
        color: color,
        fontSize: 16.0,
      ),
      maxLines: maxLines,
      overflow: overFlow,
    );
  }

  Widget _buildImageMessage() {
    if (isReply) {
      return const Icon(Icons.image);
    } else {
      return CachedNetworkImage(
        width: 200,
        height: 200,
        imageUrl: message,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildVideoMessage() {
    if (isReply) {
      return const Icon(Icons.video_collection);
    } else {
      return VideoPlayerWidget(
        videoUrl: message,
        color: color,
        viewOnly: viewOnly,
      );
    }
  }

  Widget _buildAudioMessage() {
    if (isReply) {
      return const Icon(Icons.audiotrack);
    } else {
      return AudioPlayerWidget(
        audioUrl: message,
        color: color,
        viewOnly: viewOnly,
      );
    }
  }
}
