import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_utilities/image_utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

/// A Widget that runs the example application. It allows you to pick an image
/// using the [ImagePicker] plugin and then displays the image using the
/// [Image] widget.
///
/// It uses this plugin to generate a thumbnail for the image. It also 
/// rotates the image by 90 degrees.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Image? _image;
  Image? _thumbnail;
  Image? _rotated;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image Utilities Example'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  // Request storage permissions
                  if (!(await Permission.storage.isGranted)) {
                    await Permission.storage.request();
                  }

                  if (!(await Permission.camera.isGranted)) {
                    await Permission.camera.request();
                  }

                  // Pick an image
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );

                  if (image == null) return;

                  // Generate a thumbnail
                  Directory? directory;
                  if (Platform.isAndroid) {
                    directory = await getExternalStorageDirectory();
                  } else {
                    directory = await getApplicationDocumentsDirectory();
                  }

                  final fileName = image.path.split('/').last;
                  final thumbnailPath = '${directory!.path}/$fileName';
                  final rotatedPath = '${directory.path}/rotated_$fileName';

                  await ImageUtilities().generateThumbnail(
                    imagePath: image.path,
                    targetPath: thumbnailPath,
                    maxSize: 128,
                    format: ImageUtilitiesFormat.jpeg,
                  );

                  // Rotate the image by 90 degrees
                  await ImageUtilities().rotate(
                    imagePath: image.path,
                    targetPath: rotatedPath,
                    degrees: 180,
                    format: ImageUtilitiesFormat.jpeg,
                  );

                  // Display the image
                  setState(() {
                    _image = Image.file(File(image.path));
                    _thumbnail = Image.file(File(thumbnailPath));
                    _rotated = Image.file(File(rotatedPath));
                  });
                },
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              _image ?? const SizedBox(),
              const SizedBox(height: 20),
              _thumbnail ?? const SizedBox(),
              const SizedBox(height: 20),
              _rotated ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
