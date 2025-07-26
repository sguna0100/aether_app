import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  // Replace with your backend URL
  final String _backendUrl = 'YOUR_BACKEND_URL';
  bool _isLoading = false; // Add loading state

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    final userMessage = ChatMessage(text: text, isUserMessage: true);
    setState(() {
      _messages.insert(0, userMessage);
      _isLoading = true; // Set loading to true
    });

    // Send message to backend
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/query'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'query': text,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final responseBody = jsonDecode(response.body);
        final botResponseText = responseBody['response']; // Assuming the response contains a 'response' field
        final botMessage = ChatMessage(text: botResponseText, isUserMessage: false);
        setState(() {
          _messages.insert(0, botMessage);
        });
      } else {
        // Handle non-200 status codes
        final botMessage = ChatMessage(text: 'Error: ${response.statusCode}', isUserMessage: false);
         setState(() {
          _messages.insert(0, botMessage);
        });
      }
    } catch (e) {
      // Handle network errors
      final botMessage = ChatMessage(text: 'Error: $e', isUserMessage: false);
       setState(() {
          _messages.insert(0, botMessage);
        });
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after response or error
      });
    }
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Send a message'),
              enabled: !_isLoading, // Disable input when loading
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text), // Disable button when loading
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
          if (_isLoading) // Display loading indicator when loading
            const LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    required this.text,
    required this.isUserMessage,
    super.key,
  });

  final String text;
  final bool isUserMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage)
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
                  isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(isUserMessage ? 'You' : 'Bot',
                    style: Theme.of(context).textTheme.titleMedium),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
          if (isUserMessage)
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
