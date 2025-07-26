import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:myapp/presentation/screens/chat_screen.dart';
import 'package:myapp/presentation/notifiers/chat_notifier.dart';
import 'package:myapp/domain/usecases/send_message_usecase.dart';
import 'package:myapp/data/repositories/chat_repository_impl.dart';
import 'package:myapp/data/datasources/chat_remote_datasource.dart';

void main() {
  final dio = Dio();
  // Replace with your backend URL
  const backendUrl = 'YOUR_BACKEND_URL'; 
  final remoteDataSource = ChatRemoteDataSource(dio, backendUrl);
  final chatRepository = ChatRepositoryImpl(remoteDataSource);
  final sendMessageUseCase = SendMessageUseCase(chatRepository);

  runApp(MyApp(sendMessageUseCase: sendMessageUseCase));
}

class MyApp extends StatelessWidget {
  final SendMessageUseCase sendMessageUseCase;
  const MyApp({super.key, required this.sendMessageUseCase});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatNotifier(sendMessageUseCase),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ChatScreen(),
      ),
    );
  }
}
