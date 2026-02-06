import 'package:flutter/material.dart';

class DiabeticWoundsPage extends StatefulWidget {
  @override
  _DiabeticWoundsPageState createState() => _DiabeticWoundsPageState();
}

class _DiabeticWoundsPageState extends State<DiabeticWoundsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diabetic Wounds'),
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: What are Diabetic Wounds?
              _buildSectionTitle('What are Diabetic Wounds?'),
              SizedBox(height: 8),
              _buildSectionContent(
                'Diabetic wounds are chronic wounds commonly found in individuals with diabetes. These wounds, particularly foot ulcers, can develop due to poor circulation and nerve damage—both common complications of diabetes.',
              ),
              SizedBox(height: 16),

              // Image Illustration
              Center(
                child: Image.asset(
                  'images/diabepic.jpg',
                  height: 250, // Adjust height as needed
                  fit: BoxFit.cover, // Adjust image fit as needed
                ),
              ),
              SizedBox(height: 20),

              // Section 2: Symptoms of Diabetic Wounds
              _buildSectionTitle('Symptoms of Diabetic Wounds'),
              SizedBox(height: 8),
              _buildBulletList([
                'Pain or tenderness in the affected area',
                'Swelling or redness around the wound',
                'Discharge or pus from the wound',
                'Difficulty healing or the wound worsening over time',
                'Signs of infection (fever, chills, etc.) in severe cases',
              ]),
              SizedBox(height: 20),

              // Section 3: Early Assessment
              _buildSectionTitle('Early Assessment'),
              SizedBox(height: 8),
              _buildSectionContent(
                'Early assessment of diabetic wounds is crucial to prevent complications. Key steps include:\n'
                '- Checking for sores, cuts, or ulcers\n'
                '- Assessing the size, depth, and color of the wound\n'
                '- Evaluating for infection signs (redness, warmth, drainage)\n'
                '- Monitoring blood sugar levels, as high sugar can hinder healing.',
              ),
              SizedBox(height: 20),

              // Section 4: Early Stages of the Wound
              _buildSectionTitle('Early Stages of the Wound'),
              SizedBox(height: 8),
              _buildSectionContent(
                'In the early stages, diabetic wounds may appear as red, irritated skin or a small blister. The wound is often shallow and might not cause much pain. However, if left untreated, it can progress into a more severe ulcer that becomes difficult to treat.',
              ),

              SizedBox(height: 16),

              Center(
                child: Image.asset(
                  'images/diabeticstages.png',
                  height: 130, // Adjust height as needed
                  fit: BoxFit.cover, // Adjust image fit as needed
                ),
              ),
              SizedBox(height: 20),

              // Section 5: Treatment & Prevention Tips
              _buildSectionTitle('Treatment & Prevention Tips'),
              SizedBox(height: 8),
              _buildSectionContent(
                'Effective treatment and prevention strategies include:\n'
                '- Proper wound cleaning and dressing\n'
                '- Use of antibiotics if infection is present\n'
                '- Maintaining controlled blood sugar levels\n'
                '- Comprehensive foot care for diabetic foot ulcers\n\n'
                'Prevention tips:\n'
                '- Regularly check for cuts, ulcers, or sores on the body\n'
                '- Wear well-fitting shoes to reduce foot stress\n'
                '- Keep blood sugar levels stable\n'
                '- Ensure wounds are properly cleaned and dressed.',
              ),
              SizedBox(height: 20),

              // Section 6: Seek Medical Help
              _buildSectionTitle('When to Seek Medical Help'),
              SizedBox(height: 8),
              _buildSectionContent(
                'If you notice any signs of infection or if a wound doesn\'t heal properly, seek medical attention immediately. Unattended diabetic wounds can lead to severe complications such as infections, amputations, or other serious health risks.',
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
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.teal[700],
      ),
    );
  }

  // Helper function to create section content with improved readability
  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        height: 1.6, // Increase line height for better readability
        color: Colors.black87,
      ),
    );
  }

  // Helper function to display bullet list for symptoms, prevention tips, etc.
  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        size: 6, color: Colors.teal[600]), // Bullet point
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
