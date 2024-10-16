import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receipt_manager/components/rounded_button.dart';

import '../logger.dart';
import '../services/auth_service.dart';

class ScanScreen extends StatefulWidget {
  static const String id = 'scan_screen';

  const ScanScreen({super.key});
  @override
  ScanScreenState createState() => ScanScreenState();
}

class ScanScreenState extends State<ScanScreen> {
  User? loggedInUser;

  File? _imageFile;
  String _extractedText = '';
  String _date = '';
  String _totalPrice = '';
  List<String> _items = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    copyTessdataToDocuments().then((_) {
      logger.i('Tessdata files copied successfully');
    }).catchError((error) {
      logger.e('Error copying tessdata files: $error');
    });
  }

  void getCurrentUser() async {
    loggedInUser = await AuthService.getCurrentUser();
  }

  Future<void> copyTessdataToDocuments() async {
    final directory = await getApplicationDocumentsDirectory();
    final tessdataPath = '${directory.path}/tessdata';

    final tessdataDir = Directory(tessdataPath);
    if (!(await tessdataDir.exists())) {
      await tessdataDir.create();
    }

    final languages = ['eng', 'fin'];
    for (var language in languages) {
      final traineddataAssetPath = 'assets/tessdata/$language.traineddata';
      final traineddataDestPath = '$tessdataPath/$language.traineddata';

      if (!File(traineddataDestPath).existsSync()) {
        final data = await rootBundle.load(traineddataAssetPath);
        final bytes = data.buffer.asUint8List();
        await File(traineddataDestPath).writeAsBytes(bytes);
      }
    }
    logger.i('Tessdata files copied to: $tessdataPath');
  }

  Future<void> _captureFromCamera() async {
    PermissionStatus cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        logger.i('Image path: ${pickedFile.path}');
        _performTextRecognition(_imageFile!);
      }
    } else {
      logger.w("Camera permission denied");
    }
  }

  Future<void> _pickFromGallery() async {
    PermissionStatus permissionStatus;

    if (Platform.isIOS) {
      permissionStatus = await Permission.photos.request();
    } else {
      permissionStatus = await Permission.storage.request();
    }

    if (permissionStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        logger.i('Image path: ${pickedFile.path}');
        _performTextRecognition(_imageFile!);
      }
    } else {
      logger.w("Gallery permission denied");
    }
  }

  Future<void> _performTextRecognition(File image) async {
    setState(() {
      _extractedText = "Processing...";
      _date = '';
      _totalPrice = '';
      _items = [];
    });

    try {
      String tessdataPath = '';
      if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        tessdataPath = '${directory.path}/tessdata';
      } else if (Platform.isAndroid) {
        tessdataPath = 'assets/tessdata';
      }
      logger.i('Using tessdata path: $tessdataPath');

      String text = await FlutterTesseractOcr.extractText(image.path,
          language: 'fin+eng',
          args: {
            "tessdata": tessdataPath,
            "preserve_interword_spaces": "1",
          });

      setState(() {
        _extractedText = text;
        _extractReceiptInfo(text);
      });
    } catch (e, stackTrace) {
      logger.e('Error during text recognition: $e');
      logger.i('Stack trace: $stackTrace');
      setState(() {
        _extractedText = "Error extracting text: $e";
      });
    }
  }

  void _extractReceiptInfo(String text) {
    logger.i('Extracting receipt info from:\n$text'); // Debugging line

    // Extract date
    RegExp dateRegex = RegExp(r'\b\d{1,2}[./-]\d{1,2}[./-]\d{2,4}\b');
    Match? dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      _date = dateMatch.group(0)!;
      logger.i('Date found: $_date'); // Debugging line
    } else {
      logger.w('No date found'); // Debugging line
    }

    // Extract total price
    RegExp totalRegex =
        RegExp(r'Total:?\s*€?\s*(\d+[.,]\d{2})', caseSensitive: false);
    Match? totalMatch = totalRegex.firstMatch(text);
    if (totalMatch != null) {
      _totalPrice = totalMatch.group(1)!;
      logger.i('Total price found: $_totalPrice'); // Debugging line
    } else {
      logger.w('No total price found'); // Debugging line
      // Fallback: try to find the last price in the text
      RegExp priceRegex = RegExp(r'\b\d+[.,]\d{2}\b');
      final prices =
          priceRegex.allMatches(text).map((m) => m.group(0)!).toList();
      if (prices.isNotEmpty) {
        _totalPrice = prices.last;
        logger.i('Fallback total price found: $_totalPrice'); // Debugging line
      }
    }

    // Extract items
    _items.clear();
    List<String> lines = text.split('\n');
    for (String line in lines) {
      if (line.contains(RegExp(r'\d+[.,]\d{2}')) &&
          !line.toLowerCase().contains('total')) {
        _items.add(line.trim());
      }
    }
    logger.i('Items found: ${_items.length}'); // Debugging line
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Receipt'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Text("No image selected or captured"),
            RoundedButton(
                color: Colors.lightBlueAccent,
                title: 'Capture from Camera',
                onPressed: _captureFromCamera),
            RoundedButton(
                color: Colors.lightBlue,
                title: 'Pick from Gallery',
                onPressed: _pickFromGallery),
            Text('Date: $_date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Total Price: $_totalPrice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _items.map((item) => Text('- $item')).toList(),
            ),
            SizedBox(height: 20),
            Text('Full Extracted Text:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_extractedText),
          ],
        ),
      ),
    );
  }
}
