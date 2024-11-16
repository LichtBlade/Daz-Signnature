import 'dart:io';
import 'dart:typed_data';
import 'package:daz_signature/globalVariable.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:device_info_plus/device_info_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? exportedImage;
  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
  );

  Future<bool> requestPermissions() async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      if (re.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (await Permission.storage.isGranted) {
        return true;
      } else {
        var result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> saveSignature() async {
    try {
      // Request permissions
      bool permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to save signature.')),
        );
        return;
      }

      // Export the signature as a PNG byte array
      exportedImage = await controller.toPngBytes();

      if (exportedImage != null) {
        final image = img.decodeImage(exportedImage!);
        if (image != null) {
          // Create a transparent image
          final transparentImage = img.Image(image.width, image.height);
          for (int y = 0; y < image.height; y++) {
            for (int x = 0; x < image.width; x++) {
              int pixel = image.getPixel(x, y);
              if (pixel != img.getColor(255, 255, 0, 255)) {
                transparentImage.setPixel(x, y, pixel);
              }
            }
          }

          final pngBytes = Uint8List.fromList(img.encodePng(transparentImage));

          // Get the directory to save the image
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            final filePath = '${directory.path}/${inputName}.png';
            final file = File(filePath);

            // Write the PNG bytes to the file
            await file.writeAsBytes(pngBytes);

            // Save the image to the gallery
            final success = await GallerySaver.saveImage(filePath);

            if (success != null && success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signature saved to gallery.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save signature.')),
              );
            }

            setState(() {
              exportedImage = pngBytes;
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving signature: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Daz Signature"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Signature(
              controller: controller,
              width: 350,
              height: 200,
              backgroundColor: Colors.lightBlue[100]!,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: saveSignature,
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    controller.clear();
                  },
                  child: const Text(
                    "Clear",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (exportedImage != null)
              Image.memory(
                exportedImage!,
                width: 300,
                height: 250,
              ),
          ],
        ),
      ),
    );
  }
}
