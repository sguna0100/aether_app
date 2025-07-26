import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/presentation/notifiers/chat_notifier.dart';
import 'package:myapp/domain/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(BuildContext context, String text) {
    if (text.isNotEmpty) {
      Provider.of<ChatNotifier>(context, listen: false).sendMessage(text);
      _textController.clear();
    }
  }

  Widget _buildTextComposer(BuildContext context) {
    final chatNotifier = Provider.of<ChatNotifier>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: (text) => _handleSubmitted(context, text),
              decoration:
                  const InputDecoration.collapsed(hintText: 'Send a message'),
              enabled: !chatNotifier.isLoading, // Disable input when loading
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: chatNotifier.isLoading ? null : () => _handleSubmitted(context, _textController.text), // Disable button when loading
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatNotifier = Provider.of<ChatNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAG Chatbot'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: chatNotifier.messages.length,
              itemBuilder: (_, int index) =>
                  ChatMessageWidget(message: chatNotifier.messages[index]),
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(context),
          ),
          if (chatNotifier.isLoading) // Display loading indicator when loading
            const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUserMessage)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Text('Bot'),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  message.isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(message.isUserMessage ? 'You' : 'Bot',
                    style: Theme.of(context).textTheme.titleMedium),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(message.text),
                ),
              ],
            ),
          ),
          if (message.isUserMessage)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Text('You'),
              ),
            ),
        ],
      ),
    );
  }
}
