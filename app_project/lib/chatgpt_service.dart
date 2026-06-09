import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatGptService {
  static final _apiKey = dotenv.env['OPENAI_API_KEY'];

  static Future<String> sendMessage(String message) async {
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': message}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['choices'][0]['message']['content'];
      return reply.trim();
    } else {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}'); // print full error
      throw Exception('Failed to fetch ChatGPT response');
    }

  }
}
