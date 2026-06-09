import 'package:flutter/material.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({super.key});

  @override
  State<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage> {
  bool _agreedToDisclaimer = false;

  @override
  Widget build(BuildContext context) {
    final bool _canContinue = _agreedToDisclaimer;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to PHMS"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Adding some space at the top of the screen to move everything lower
            SizedBox(height: 40),  // Adjust this value to move the content further down

            // Welcome GIF
            SizedBox(
              height: 150,
              child: Image.asset('assets/disclaimer.gif'), // Add this to pubspec.yaml
            ),
            const SizedBox(height: 20),

            // Adding some space at the top of the screen to move everything lower
            SizedBox(height: 20),  // Adjust this value to move the content further down

            // Disclaimer Text inside a Container to control the width
            Container(
              width: 280,  // Set the width you want
              child: const Text(
                "⚠️ This is a prototype medical chatbot intended to showcase usability and feasibility. All suggestions provided are for reference only.\n\n"
                    "🩺 For serious medical concerns, please consult professional healthcare providers for physical examinations.\n\n"
                    "🛡️ All patient data is encrypted and will be treated with strict privacy according to PDPA Act 2010.",
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            // Checkbox 1
            CheckboxListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),  // Reduce padding around the checkbox
              title: Container(
                width: 250,  // Adjust the width of the text here
                child: const Text(
                  "I acknowledge the above information.",
                  style: TextStyle(fontSize: 14),  // Set the desired font size
                  overflow: TextOverflow.ellipsis,  // Optional: truncate the text if it's too long
                ),
              ),
              value: _agreedToDisclaimer,
              onChanged: (value) {
                setState(() {
                  _agreedToDisclaimer = value!;
                });
              },
            ),

            const Spacer(),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue
                    ? () {
                  Navigator.pushReplacementNamed(context, '/chat');
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Agree & Continue", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
