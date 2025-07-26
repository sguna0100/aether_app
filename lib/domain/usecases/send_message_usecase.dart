import 'package:myapp/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<String> call(String message) {
    return repository.sendMessage(message);
  }
}