import 'package:flutter/material.dart';

class VenousWoundsPage extends StatefulWidget {
  @override
  _VenousWoundsPageState createState() => _VenousWoundsPageState();
}

class _VenousWoundsPageState extends State<VenousWoundsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venous Wounds'),
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: What are Venous Wounds?
              _buildSectionTitle('What are Venous Wounds?'),
              SizedBox(height: 8),
              Text(
                'Venous wounds, also known as venous leg ulcers, are caused by poor circulation due to problems in the veins, typically in the lower legs. These ulcers occur when blood pools in the veins, increasing pressure in the leg and causing the skin to break down.',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),

              Center(
                child: Image.asset(
                  'images/venouspic.jpg',
                  height: 200, // Adjust height as needed
                  fit: BoxFit.cover, // Adjust image fit as needed
                ),
              ),
              SizedBox(height: 20),

              // Section 2: Symptoms of Venous Wounds
              _buildSectionTitle('Symptoms of Venous Wounds'),
              SizedBox(height: 8),
              Text(
                'The symptoms include:\n'
                '- Swelling and heaviness in the legs\n'
                '- Pain, especially when standing or walking\n'
                '- Brownish discoloration of the skin\n'
                '- Slow-healing ulcers on the lower leg or ankle\n'
                '- Skin that may feel tight or warm',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Section 3: Early Assessment
              _buildSectionTitle('Early Assessment'),
              SizedBox(height: 8),
              Text(
                'Early signs of venous wounds include swelling, skin discoloration, and itching. Patients may also experience pain, especially after standing for prolonged periods. Timely medical assessment is important to manage these symptoms and prevent ulceration.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Section 4: Early Stages of the Wound
              _buildSectionTitle('Early Stages of the Wound'),
              SizedBox(height: 8),
              Text(
                'In the early stages, venous ulcers may appear as small, shallow open sores on the lower legs or ankles. They may not be very painful initially but will worsen if left untreated. Proper care and treatment are essential to prevent the ulcer from growing.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Center(
                child: Image.asset(
                  'images/venoustages.png',
                  height: 190, // Adjust height as needed
                  fit: BoxFit.cover, // Adjust image fit as needed
                ),
              ),
              SizedBox(height: 20),

              // Section 5: Treatment & Prevention Tips
              _buildSectionTitle('Treatment & Prevention Tips'),
              SizedBox(height: 8),
              Text(
                'Treatment for venous ulcers includes:\n'
                '- Compression therapy to improve blood flow\n'
                '- Wound cleaning and dressing\n'
                '- Antibiotics if an infection is present\n\n'
                'Prevention tips:\n'
                '- Elevating the legs to reduce swelling\n'
                '- Wearing compression stockings\n'
                '- Maintaining a healthy weight and exercise routine',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              // Section 6: Seek Medical Help
              _buildSectionTitle('When to Seek Medical Help'),
              SizedBox(height: 8),
              Text(
                'If the wound does not heal or worsens despite treatment, or if signs of infection such as redness, warmth, or discharge are present, medical attention is needed to prevent serious complications.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal[700],
      ),
    );
  }
}
