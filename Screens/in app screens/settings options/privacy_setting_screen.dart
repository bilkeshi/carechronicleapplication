import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isDataSharingEnabled = true;
  bool _isLocationTrackingEnabled = true;

  void _savePrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy settings saved successfully!')),
    );
  }

  void _clearPersonalData() {
    setState(() {
      _isDataSharingEnabled = false;
      _isLocationTrackingEnabled = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Personal data cleared. Settings reset.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text('Data Sharing'),
              subtitle: Text(
                  'Enable or disable sharing your data with third parties'),
              value: _isDataSharingEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isDataSharingEnabled = value;
                });
              },
            ),
            Divider(),
            SwitchListTile(
              title: Text('Location Tracking'),
              subtitle: Text('Allow the app to access your location'),
              value: _isLocationTrackingEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isLocationTrackingEnabled = value;
                });
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: _clearPersonalData,
                child: Text('Clear Personal Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: _savePrivacySettings,
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
