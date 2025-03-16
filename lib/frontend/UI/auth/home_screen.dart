import 'package:accento/frontend/UI/auth/profile_screen.dart';
import 'package:accento/frontend/UI/auth/saved_voices_screen.dart';
import 'package:accento/frontend/widgets/custom_bottom_navbar.dart';
import 'package:accento/utilities/constants.dart';
import 'package:accento/utilities/theme.dart';
import 'package:accento/utilities/urls.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  final String? voiceId;
  final String? filePath;
  final File? audioFile;

  const HomeScreen({super.key, this.voiceId, this.filePath, this.audioFile});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "";
  String _geminiResponse = "";
  late String apiKey;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    await dotenv.load();
    setState(() {
      apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    });
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint("Speech Status: $status"),
      onError: (error) => debugPrint("Speech Error: $error"),
    );
    if (!available) {
      debugPrint("Speech-to-Text Not Available");
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _text = _cleanUserInput(_text); // Refine user input
        _getGeminiResponse(_text);
        debugPrint("cleaned text: $_text");
      });
    } else {
      setState(() {
        _isListening = true;
        _text = ""; // Reset text when starting new speech
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  /// **Refine user input before sending to Gemini**
  String _cleanUserInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// **Send text to Gemini AI**
  Future<void> _getGeminiResponse(String userSpeech) async {
    if (userSpeech.isEmpty) return;

    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Provide a **direct** and **concise** response to: $userSpeech. Avoid asking follow-up questions."
                }
              ]
            }
          ],
          "generationConfig": {
            "maxOutputTokens": 100 // Limit response length
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["candidates"]?.isNotEmpty ?? false) {
          String responseText = data["candidates"][0]["content"]["parts"][0]
                  ["text"] ??
              "No response.";

          responseText = _cleanGeminiResponse(responseText); // Process response
          setState(() => _geminiResponse = responseText);
          _generateVoiceResponse(responseText);
          debugPrint("gemini's response: $_geminiResponse");
          debugPrint("responseText: $responseText");
        } else {
          setState(() => _geminiResponse = "No response from Gemini AI.");
        }
      } else {
        setState(() =>
            _geminiResponse = "Error: Failed to get response from Gemini.");
      }
    } catch (e) {
      debugPrint("Error fetching Gemini response: $e");
    }
  }

  /// **Process Gemini's response to remove redundant parts**
  String _cleanGeminiResponse(String response) {
    response = response.replaceAll(RegExp(r'[*_`]'), ""); // Remove markdown
    response =
        response.replaceAll(RegExp(r'\s+'), ' ').trim(); // Remove extra spaces

    // Cut off any unnecessary explanations (e.g., if it starts with "Sure, here's...")
    if (response.contains("Here's") || response.contains("Sure,")) {
      int index = response.indexOf(":");
      if (index != -1 && index + 1 < response.length) {
        response = response.substring(index + 1).trim();
      }
    }

    // Ensure the response is brief and meaningful
    List<String> sentences = response.split('. ');
    if (sentences.length > 2) {
      response =
          "${sentences.sublist(0, 2).join('. ')}."; // Keep only the first two sentences
    }

    return response;
  }

  Future<void> _generateVoiceResponse(String aiResponse) async {
    // final String baseUrl = "http://192.168.202.33:8000";

    try {
      final response = await http.post(
        Uri.parse("${AppConstants.apiUrl}/synthesize"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"text": _formatTTSOutput(aiResponse)},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String audioPath = data['audio_file']; // Get relative path

        // Ensure the final URL is correctly formatted
        String audioFilePath =
            Uri.parse(AppConstants.apiUrl).resolve(audioPath).toString();

        _playVoiceResponse(audioFilePath);
      } else {
        debugPrint("TTS API error: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in FastAPI API: $e");
    }
  }

  /// **Reformat TTS output for a more natural speech flow**
  String _formatTTSOutput(String text) {
    return text.replaceAll(
        '.', '. '); // Ensure proper spacing for better speech flow
  }

  /// **Play AI-generated response**
  Future<void> _playVoiceResponse(String fileUrl) async {
    try {
      // await _audioPlayer.play(UrlSource("http://192.168.2.88:8000/static/generated_speech.wav"));
      await _audioPlayer.play(UrlSource(AppConstants.audioUrl));
    } catch (e) {
      debugPrint("Error playing file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        onListPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavedVoices()),
          );
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        onMicPressed: () {
          // _startListening();
        },
        onPressed: () {},
      ),
      floatingActionButton: CustomFAB(
        onPressed: _toggleListening,
        icon: _isListening ? Icons.mic_off : Icons.mic,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      _isListening
                          ? "Accento Listening..."
                          : "Accento Speaking...",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // const SizedBox(height: 60), // Adds space between text and animation
                    Lottie.asset(
                      'assets/images/animation.json',
                      width: AppSizes.wp(280),
                      height: AppSizes.hp(280),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
