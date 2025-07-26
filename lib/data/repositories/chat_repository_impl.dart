import 'package:myapp/domain/repositories/chat_repository.dart';
import 'package:myapp/data/datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> sendMessage(String message) {
    return remoteDataSource.sendMessage(message);
  }
}