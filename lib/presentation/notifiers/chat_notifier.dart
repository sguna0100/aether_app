import 'package:flutter/material.dart';
import 'package:myapp/domain/models/chat_message.dart';
import 'package:myapp/domain/usecases/send_message_usecase.dart';

class ChatNotifier extends ChangeNotifier {
  final SendMessageUseCase sendMessageUseCase;

  ChatNotifier(this.sendMessageUseCase);

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(text: text, isUserMessage: true);
    _messages.insert(0, userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final botResponseText = await sendMessageUseCase(text);
      final botMessage = ChatMessage(text: botResponseText, isUserMessage: false);
      _messages.insert(0, botMessage);
    } catch (e) {
      final botMessage = ChatMessage(text: 'Error: $e', isUserMessage: false);
      _messages.insert(0, botMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}