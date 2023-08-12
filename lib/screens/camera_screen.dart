import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../reusable_widgets/expandable_fab.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? message = '';
  File? selectedImage;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Future getImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(pickedImage!.path);

    setState(() {});
  }

  Future getImageFromCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    selectedImage = File(pickedImage!.path);

    setState(() {});
  }

  _scanImage() async {
    setState(() {
      isLoading = true;
    });
    final request = http.MultipartRequest(
        "POST", Uri.parse("http://localhost:4000/upload"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: selectedImage!.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    log(message.toString());

    setState(() {
      isLoading = false;
    });

    //await convertToPdf(message); // Convert the extracted text to PDF
  }

  // Function to create PDF and insert the extracted text
  /*Future<void> convertToPdf(String? extractedText) async {
    final pdf = pdfWidgets.Document();
    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Text(extractedText ?? ''),
          );
        },
      ),
    );

    final output = await File('output.pdf').create();
    await output.writeAsBytes(await pdf.save());
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devanagari OCR'),
      ),
      floatingActionButton: ExpandableFab(
        distance: 70,
        children: [
          ActionButton(
            title: 'Camera',
            onPressed: getImageFromCamera,
            icon: const Icon(
              Icons.camera,
              color: Colors.white,
              size: 15,
            ),
          ),
          ActionButton(
            title: 'Gallery',
            onPressed: getImage,
            icon: const Icon(Icons.photo_album),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SingleChildScrollView(
          child: selectedImage == null
              ? const Center(child: Text("Please pick a image to scan"))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.file(selectedImage!, fit: BoxFit.contain),
                    ElevatedButton(
                        onPressed: _scanImage, child: const Text('Scan')),
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Text(
                            'Scanned Text',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            '$message',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}// ngrok http 4000