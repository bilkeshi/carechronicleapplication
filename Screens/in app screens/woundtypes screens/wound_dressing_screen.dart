import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WoundDressingScreen extends StatefulWidget {
  const WoundDressingScreen({Key? key}) : super(key: key);

  @override
  State<WoundDressingScreen> createState() => _WoundDressingScreenState();
}

class _WoundDressingScreenState extends State<WoundDressingScreen> {
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wound Dressing'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wound Dressing: An Essential Practice',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7165D6),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Proper wound care is crucial for preventing infections, promoting healing, and reducing the risk of complications. '
                'In this section, you will find video resources on different types of wounds and how to manage them with proper dressing techniques.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              Text(
                'Select a wound type to learn more:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              WoundOption(
                title: 'Diabetic Wounds',
                description:
                    'Learn how to manage diabetic wounds and prevent complications.',
                onPressed: () {
                  _launchURL(
                      'https://www.youtube.com/watch?v=example_diabetic');
                },
              ),
              SizedBox(height: 16),
              WoundOption(
                title: 'Venous Wounds',
                description:
                    'Learn about venous ulcers and the proper dressing techniques.',
                onPressed: () {
                  _launchURL('https://www.youtube.com/watch?v=example_venous');
                },
              ),
              SizedBox(height: 16),
              WoundOption(
                title: 'Pressure Wounds',
                description:
                    'Understand how to care for pressure ulcers effectively.',
                onPressed: () {
                  _launchURL(
                      'https://www.youtube.com/watch?v=example_pressure');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WoundOption extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  WoundOption({
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Color(0xFF9A7AE1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.video_library, color: Colors.white, size: 30),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
