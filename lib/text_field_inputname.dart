import 'package:daz_signature/home.dart';
import 'package:flutter/material.dart';
import 'package:daz_signature/GlobalVariable.dart';

class InputName extends StatefulWidget {
  const InputName({super.key});

  @override
  State<InputName> createState() => _InputNameState();
}

class _InputNameState extends State<InputName> {
  final TextEditingController fileNameController = TextEditingController();

  void handleNext() {
    // Trim the input and check if it's empty
    final name = fileNameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        inputName = name; // Assign the value to inputName
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
      // Navigate or use the inputName value as needed

      // Here you could navigate to another screen or perform other actions.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid file name')),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: fileNameController,
                decoration: const InputDecoration(
                  labelText: 'Enter Your FullName',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleNext,
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
