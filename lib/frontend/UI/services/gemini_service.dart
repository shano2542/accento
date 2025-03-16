import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey =
      "AIzaSyDQAqYbmP0cKsBnGZgCvgoV0YIigQfTjQc"; // Replace with your API Key
  Future<String> generateText(String prompt) async {
    final String url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "No response from AI.";
      }
    } else {
      throw Exception("Failed to generate text: ${response.body}");
    }
  }
}
