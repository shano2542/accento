import 'dart:io';
import 'dart:typed_data';
import 'package:accento/frontend/UI/auth/profile_screen.dart';
import 'package:accento/frontend/widgets/custom_bottom_navbar.dart';
import 'package:accento/frontend/widgets/custom_button.dart';
import 'package:accento/frontend/widgets/custom_voice_field.dart';
import 'package:accento/utilities/toast_message.dart';
import 'package:accento/utilities/urls.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:accento/utilities/theme.dart';
import 'package:accento/frontend/UI/auth/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class SavedVoices extends StatefulWidget {
  const SavedVoices({super.key});

  @override
  _SavedVoicesState createState() => _SavedVoicesState();
}

class _SavedVoicesState extends State<SavedVoices> {
  // final String apiUrl = "http://192.168.202.33:8000";
  bool isUploading = false;
  List<String> audioUrls = [];
  String? selectedAudio;
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchAudioIds();
  }

  Future<void> pickAndUploadFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null) {
      File pickedFile = File(result.files.single.path!);

      setState(() {
        isUploading = true;
      });

      String uploadedFilePath = await uploadFileToFastAPI(pickedFile);

      if (uploadedFilePath.isNotEmpty) {
        ToastMessage().toastMessage("Audio file uploaded successfully!",
            backgroundColor: Colors.green);
        fetchAudioIds();
      } else {
        ToastMessage().toastMessage("Error uploading audio file.");
      }

      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String> uploadFileToFastAPI(File file) async {
    try {
      Uint8List fileBytes = await file.readAsBytes();
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${AppConstants.apiUrl}/upload_audio"),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          fileBytes,
          filename: basename(file.path),
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return "${AppConstants.apiUrl}/uploads/${basename(file.path)}";
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<void> fetchAudioIds() async {
    try {
      print("Fetching audio files...");
      final response = await http.get(Uri.parse("${AppConstants.apiUrl}/fetch_audio_ids"));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract values (filenames) from the map
        Map<String, String> audioMap =
            Map<String, String>.from(jsonResponse["audio_files"]);
        List<String> ids = audioMap.values.toList();

        setState(() {
          audioUrls = ids.map((id) => "${AppConstants.apiUrl}/uploads/$id").toList();
        });

        debugPrint("Fetched audio URLs: $audioUrls");
      } else {
        debugPrint(
            "Failed to fetch audio files. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching audio files: $e");
    }
  }

  Future<void> selectAudioAsDefault() async {
    if (selectedAudio == null) {
      ToastMessage().toastMessage("Please select an audio file first.");
      return;
    }

    try {
      // Extract filename without extension from URL
      String filename = selectedAudio!.split('/').last.split('.').first;

      final response = await http.post(
        Uri.parse("${AppConstants.apiUrl}/select_audio"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "audio_id": filename, // ✅ Sends only the UUID (without .mp3)
        },
      );

      if (response.statusCode == 200) {
        ToastMessage().toastMessage("Default voice selected successfully!",backgroundColor: Colors.green);
      } else {
        debugPrint("Error Response: ${response.body}");
        ToastMessage().toastMessage("Failed to select audio.");
      }
    } catch (e) {
      debugPrint("Error selecting audio: $e");
      ToastMessage().toastMessage("Error selecting audio.");
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        onPressed: () {},
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        icon: Icons.mic,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Container(decoration: AppGradient.gradientBG),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 70),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Upload Your Voice",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColorLight)),
                    const SizedBox(height: 20),
                    CustomButton(
                        text: isUploading ? "Uploading..." : "Upload Voice",
                        onPressed: isUploading ? null : pickAndUploadFile),
                    const SizedBox(height: 20),
                    const Text("Select a Voice File",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColorLight)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: audioUrls.isEmpty
                          ? const Center(
                              child: Text("No saved voices found.",
                                  style:
                                      TextStyle(color: AppTheme.textColorDark)))
                          : ListView.builder(
                              itemCount: audioUrls.length,
                              itemBuilder: (context, index) {
                                return SingleChildScrollView(
                                  child: CustomVoiceField(
                                    selectedVoice: RadioListTile<String>(
                                      title: Text("Voice ${index + 1}"),
                                      value: audioUrls[index],
                                      groupValue: selectedAudio,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAudio = value;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    CustomButton(
                      text: "Select Voice",
                      onPressed: selectAudioAsDefault
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}