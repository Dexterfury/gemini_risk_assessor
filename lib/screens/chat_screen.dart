import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/widgets/bottom_chat_field.dart';
import 'package:gemini_risk_assessor/widgets/message_bubble.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.docID = '',
    this.isTool = false,
  });

  final String docID;
  final bool isTool;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  SpeechToText _speechToText = SpeechToText();
  AudioPlayer? _audioPlayer = AudioPlayer();
  AudioPlayer? _audioPlayer2 = AudioPlayer();

  String _spokenWords = '';

  @override
  void dispose() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    _scrollController.dispose();
    _audioPlayer!.dispose();
    _audioPlayer2!.dispose();
    super.dispose();
  }

  setPlayerListener() async {
    final chatProvider = context.read<ChatProvider>();

    // for replay audio
    await _audioPlayer2!.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed);
    chatProvider.setGeminiTalking(value: false);
    // Reset player for the next audio
    await _audioPlayer2!.stop();
    await _audioPlayer2!.seek(Duration.zero);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _start({required bool isClicked}) async {
    final chatProvider = context.read<ChatProvider>();
    final uid = context.read<AuthProvider>().userModel!.uid;
    bool isAvailable = await _speechToText.initialize();

    if (isClicked && isAvailable) {
      chatProvider.setIsListening(listening: true);

      await _speechToText.listen(
        onResult: (result) async {
          _spokenWords = result.recognizedWords;

          await chatProvider.addAndDisplayMessage(
            uid: uid,
            chatID: widget.docID,
            isTool: widget.isTool,
            finalWords: result.finalResult,
            spokenWords: _spokenWords,
            onSuccess: () {},
            onError: (error) {},
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.messages.isNotEmpty) {
          _scrollToBottom();
        }

        // auto scroll to bottom on new message
        chatProvider.addListener(() {
          if (chatProvider.messages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text('Chat with Gemini'),
            actions: [
              if (chatProvider.messages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        // show my animated dialog to start new chat
                      },
                    ),
                  ),
                )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.messages.isEmpty
                        ? const Center(
                            child: Text('No messages yet'),
                          )
                        : MessageBubble(
                            scrollController: _scrollController,
                            chatProvider: chatProvider,
                          ),
                  ),

                  // input field
                  BottomChatField(
                    chatProvider: chatProvider,
                    docID: widget.docID,
                    isTool: widget.isTool,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
