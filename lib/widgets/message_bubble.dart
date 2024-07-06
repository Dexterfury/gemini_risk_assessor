import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gemini_risk_assessor/models/message.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return Column(children: [
          _userMessage(context, message),
          const SizedBox(
            height: 5,
          ),
          _geminiMessage(context, message),
        ]);
      },
    );
  }

  _userMessage(BuildContext context, Message message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: MarkdownBody(
          selectable: true,
          data: message.question,
        ),
      ),
    );
  }

  _geminiMessage(BuildContext context, Message message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 8),
          child: message.answer.isEmpty
              ? const SizedBox(
                  width: 50,
                  child: SpinKitThreeBounce(
                    color: Colors.blueGrey,
                    size: 20.0,
                  ),
                )
              : MarkdownBody(
                  selectable: true,
                  data: message.answer.toString(),
                )),
    );
  }
}
