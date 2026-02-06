import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey =
      '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'; // API Key

  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(
          'https://api.openai.com/v1/chat/completions'), // Correct API URL for ChatGPT
      headers: {
        'Authorization': 'Bearer $apiKey', // Bearer token for authorization
        'Content-Type':
            'application/json', // Content type for JSON request body
      },
      body: jsonEncode({
        'model':
            'gpt-3.5-turbo', // Specify the model you're using (GPT-3.5 or GPT-4)
        'messages': [
          {'role': 'user', 'content': prompt}, // Send the user's message
        ],
        'max_tokens': 150, // Limit response length
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']
          ['content']; // Extract the message content
    } else {
      throw Exception('Failed to generate response: ${response.body}');
    }
  }
}
