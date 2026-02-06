import 'package:flutter/material.dart';

import 'privacy_setting_screen.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  String? _selectedLanguage = 'English';
  double _fontSize = 16.0;

  List<double> _availableFontSizes = [12.0, 14.0, 16.0, 18.0, 20.0];

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('General Settings'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Language Setting
            ListTile(
              title: Text('Language'),
              subtitle: Text(_selectedLanguage!),
              trailing: Icon(Icons.language),
              onTap: () async {
                final String? selected = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Select Language'),
                      children: <Widget>[
                        SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context, 'English');
                          },
                          child: Text('English'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context, 'Mandarin');
                          },
                          child: Text('Mandarin'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context, 'Bahasa Melayu');
                          },
                          child: Text('Bahasa Melayu'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            Navigator.pop(context, 'Tamil');
                          },
                          child: Text('Tamil'),
                        ),
                      ],
                    );
                  },
                );
                if (selected != null) {
                  setState(() {
                    _selectedLanguage = selected;
                  });
                }
              },
            ),
            Divider(),

            // Font Size Picker using horizontal scroll with dots
            ListTile(
              title: Text('Font Size'),
              subtitle: Text('Size: ${_fontSize.toStringAsFixed(0)}'),
              trailing: Icon(Icons.text_fields),
              onTap: () async {
                final double? selectedFontSize = await showDialog<double>(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Select Font Size'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SingleChildScrollView(
                            scrollDirection:
                                Axis.horizontal, // Make it scrollable
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _availableFontSizes.map((size) {
                                bool isSelected = _fontSize == size;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context, size);
                                  },
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Color(0xFF7165D6)
                                          : Colors.grey.shade300,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        '${size.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
                if (selectedFontSize != null) {
                  setState(() {
                    _fontSize = selectedFontSize;
                  });
                }
              },
            ),
            Divider(),

            // Privacy Settings
            ListTile(
              title: Text('Privacy Settings'),
              subtitle: Text('Manage data sharing preferences'),
              trailing: Icon(Icons.lock),
              onTap: () {
                // Navigate to Privacy Settings Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacySettingsScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigating to privacy settings')),
                );
              },
            ),
            Divider(),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7165D6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
