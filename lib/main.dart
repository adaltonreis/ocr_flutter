import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';

void main() => runApp(const OCRApp());

class OCRApp extends StatelessWidget {
  const OCRApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp(home: OCRHome(), debugShowCheckedModeBanner: false);
}

class OCRHome extends StatefulWidget {
  @override
  State<OCRHome> createState() => _OCRHomeState();
}

class _OCRHomeState extends State<OCRHome> {
  File? _image;
  String _extractedText = "";
  final picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _image = File(pickedFile.path));

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    setState(() => _extractedText = recognizedText.text);
    await textRecognizer.close();
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _extractedText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("God's eye (OCR Scanner)")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 200),
            const SizedBox(height: 10),
            Expanded(child: SingleChildScrollView(child: Text(_extractedText))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _getImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _getImage(ImageSource.gallery),
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                ),
                ElevatedButton.icon(
                  onPressed: _extractedText.isNotEmpty ? _copyText : null,
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
