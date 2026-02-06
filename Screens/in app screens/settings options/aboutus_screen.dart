import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildDescription(),
            SizedBox(height: 30),
            _buildMotto(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Chronical',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your Partner in Chronic Wound Care',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Care Chronical is a mobile app designed to help patients manage and track chronic wounds from the comfort of their homes. In Singapore, common types of chronic wounds include diabetic ulcers, pressure sores, and venous ulcers. Our goal is to empower patients to monitor their wounds consistently, helping to prevent complications and unnecessary distress. By making wound care easier and more accessible, we aim to reduce the burden on patients and caregivers, while raising awareness about the importance of early detection to avoid more severe chronic cases.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'We are committed to breaking the misconception that slow healing is simply a result of age, and to encourage patients to seek medical attention before a wound becomes infected or worsens.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotto() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            '"Consistent Care, Complete Healing"',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
