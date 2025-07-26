import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'firebase_options.dart'; // Make sure you have this file for Firebase initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Chat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AudioRecorderScreen(),
    );
  }
}

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Check and request permissions
    if (!await _audioRecorder.hasPermission()) {
      // Handle permission denial
      print("Microphone permission denied");
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/my_audio.m4a';

        await _audioRecorder.start(path: path);
        setState(() {
          _isRecording = true;
          _audioPath = path;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      if (_audioPath != null) {
        await _uploadAudio(_audioPath!);
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _uploadAudio(String filePath) async {
    try {
      File file = File(filePath);
      String fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('audio_uploads').child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Audio uploaded successfully! Download URL: $downloadUrl');

      // TODO: Send this downloadUrl to your backend (Cloud Function) for processing
      // Example: await _sendAudioUrlToBackend(downloadUrl);

    } catch (e) {
      print('Error uploading audio: $e');
    }
  }

  // TODO: Implement this function to send the URL to your Cloud Function
  // Future<void> _sendAudioUrlToBackend(String url) async {
  //   // Use http or dio to send the URL to your Cloud Function endpoint
  // }


  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Chat Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isRecording)
              const Text('Recording...', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}