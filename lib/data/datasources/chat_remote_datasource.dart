import 'package:dio/dio.dart';

class ChatRemoteDataSource {
  final Dio dio;
  final String backendUrl;

  ChatRemoteDataSource(this.dio, this.backendUrl);

  Future<String> sendMessage(String message) async {
    try {
      final response = await dio.post(
        '$backendUrl/query',
        data: {'query': message},
      );
      if (response.statusCode == 200) {
        return response.data['response'];
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}