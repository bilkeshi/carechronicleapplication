import 'package:flutter/material.dart';

class PressureWoundsPage extends StatefulWidget {
  @override
  _PressureWoundsPageState createState() => _PressureWoundsPageState();
}

class _PressureWoundsPageState extends State<PressureWoundsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pressure Wounds'),
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('What are Pressure Wounds?'),
              SizedBox(height: 8),
              Text(
                'Pressure wounds, also known as pressure ulcers or bedsores, are injuries to the skin and underlying tissue caused by prolonged pressure on the skin. These commonly occur in areas with little fat or muscle padding, such as heels, hips, and the lower back.',
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 16),

              Center(
                child: Image.asset(
                  'images/presspic.jpg',
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),

              _buildSectionTitle('Symptoms of Pressure Wounds'),
              SizedBox(height: 8),
              Text(
                'Symptoms include:\n'
                '- Red or discolored skin\n'
                '- Swelling and warmth around the area\n'
                '- Pain or tenderness\n'
                '- Open sores or blisters\n'
                '- In severe cases, the skin may break open and expose underlying tissue.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              _buildSectionTitle('Early Assessment'),
              SizedBox(height: 8),
              Text(
                'Early signs of pressure wounds involve redness that doesn\'t go away after the pressure is relieved. Regular repositioning of patients, proper support surfaces, and routine checks for pressure points are vital for early detection.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              _buildSectionTitle('Early Stages of the Wound'),
              SizedBox(height: 8),
              Text(
                'The early stages of pressure ulcers may appear as a red area on the skin that doesn’t turn white when pressed. If not treated, the wound may progress to an ulcer and become harder to heal. Immediate action can help prevent further tissue damage.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Center(
                child: Image.asset(
                  'images/pressurestages.jpg',
                  height: 105,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),

              // Section 5: Treatment & Prevention Tips
              _buildSectionTitle('Treatment & Prevention Tips'),
              SizedBox(height: 8),
              Text(
                'Treatment options include:\n'
                '- Repositioning frequently to relieve pressure\n'
                '- Using pressure-relieving mattresses and cushions\n'
                '- Keeping the wound clean and covered\n'
                '- Surgical debridement (in severe cases)\n\n'
                'Prevention includes:\n'
                '- Repositioning every 2 hours\n'
                '- Using proper cushioning and support\n'
                '- Maintaining good nutrition and hydration',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              _buildSectionTitle('When to Seek Medical Help'),
              SizedBox(height: 8),
              Text(
                'If a pressure wound worsens or does not improve with proper care, seek medical attention. In severe cases, infections or even amputations may result from untreated pressure wounds.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
