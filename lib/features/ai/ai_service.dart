import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const apiKey = String.fromEnvironment('OPENROUTER_API_KEY');

  Future<String> summarizeNote(String text) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "openai/gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a helpful assistant that summarizes student notes clearly.",
          },
          {
            "role": "user",
            "content": "Summarize this note in simple bullet points:\n\n$text",
          },
        ],
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      return "Failed to generate summary.";
    }
  }
}
