import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Variables to track notification settings
  bool _isNotificationsEnabled = true;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  bool _isQuietHoursEnabled = false;

  // Quiet Hours Time Range
  TimeOfDay _quietHoursStart =
      TimeOfDay(hour: 22, minute: 0); // Default start time: 10:00 PM
  TimeOfDay _quietHoursEnd =
      TimeOfDay(hour: 6, minute: 0); // Default end time: 6:00 AM

  // Save the notification settings
  void _saveNotificationSettings() {
    // Here you would save these settings using shared preferences or an API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification settings saved successfully!')),
    );
  }

  // Function to show time picker for quiet hours
  Future<void> _selectQuietHoursTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietHoursStart : _quietHoursEnd,
    );
    if (picked != null &&
        picked != (isStartTime ? _quietHoursStart : _quietHoursEnd)) {
      setState(() {
        if (isStartTime) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Enable/Disable Notifications
            SwitchListTile(
              title: Text('Enable Notifications'),
              subtitle: Text('Toggle to enable or disable all notifications'),
              value: _isNotificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isNotificationsEnabled = value;
                });
              },
            ),
            Divider(),

            // Enable/Disable Sound
            SwitchListTile(
              title: Text('Enable Sound'),
              subtitle: Text('Toggle to enable or disable notification sounds'),
              value: _isSoundEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isSoundEnabled = value;
                });
              },
            ),
            Divider(),

            // Enable/Disable Vibration
            SwitchListTile(
              title: Text('Enable Vibration'),
              subtitle: Text(
                  'Toggle to enable or disable vibration for notifications'),
              value: _isVibrationEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isVibrationEnabled = value;
                });
              },
            ),
            Divider(),

            // Quiet Hours Toggle
            SwitchListTile(
              title: Text('Enable Quiet Hours'),
              subtitle: Text('Mute notifications during specific hours'),
              value: _isQuietHoursEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isQuietHoursEnabled = value;
                });
              },
            ),
            if (_isQuietHoursEnabled) ...[
              // Quiet Hours Start Time
              ListTile(
                title: Text('Quiet Hours Start'),
                subtitle: Text(_quietHoursStart.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectQuietHoursTime(true),
              ),
              Divider(),

              // Quiet Hours End Time
              ListTile(
                title: Text('Quiet Hours End'),
                subtitle: Text(_quietHoursEnd.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectQuietHoursTime(false),
              ),
              Divider(),
            ],

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: _saveNotificationSettings,
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
