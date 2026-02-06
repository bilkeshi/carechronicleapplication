import 'package:care_chronicle_app/Screens/main%20screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Languages'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB3E5FC),
              Colors.white,
              // Light blue gradient
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Select a language",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "选择语言",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Pilih bahasa",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "மொழி தேர்ந்தெடு",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildLanguageButton(context, 'English', 'English'),
              SizedBox(height: 15),
              _buildLanguageButton(context, '官话', 'Mandarin'),
              SizedBox(height: 15),
              _buildLanguageButton(context, 'Bahasa Melayu', 'Malay'),
              SizedBox(height: 15),
              _buildLanguageButton(context, 'தமிழ்', 'Tamil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
      BuildContext context, String text, String language) {
    return ElevatedButton(
      onPressed: () {
        _setLanguageAndProceed(context, language);
      },
      style: ElevatedButton.styleFrom(
        padding:
            EdgeInsets.symmetric(vertical: 15), // Padding inside the button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
        ),
        elevation: 5, // Shadow for a more 3D effect
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  void _setLanguageAndProceed(BuildContext context, String language) {
    // Save language selection and navigate to the Login Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              WelcomeScreen()), // Replace with your login/home screen
    );
  }
}
