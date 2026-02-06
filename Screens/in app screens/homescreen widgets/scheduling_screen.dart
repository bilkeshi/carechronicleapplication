import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SchedulingScreen extends StatefulWidget {
  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final List<String> clinics = [
    'National Healthcare Group - Kallang',
    'National Healthcare Group - Sembawang',
    'National Healthcare Group - Ang Mo Kio',
    'National Healthcare Group - Geylang',
    'National Healthcare Group - Hougang',
    'National Healthcare Group - Toa Payoh',
    'National Healthcare Group - Woodlands',
    'National Healthcare Group - Yishun',
    'Singhealth - Bedok',
    'Singhealth - Bukit Merah',
    'Singhealth - Marine Parade',
    'Singhealth - Outram',
    'Singhealth - Pasir Ris',
    'Singhealth - Sengkang',
    'Singhealth - Tampines',
    'National University - Bukit Batok',
    'National University - Bukit Panjang',
    'National University - Choa Chu Kang',
    'National University - Clementi',
    'National University - Jurong',
    'National University - Pioneer',
    'National University - Queenstown',
  ];

  String? selectedClinic;
  String? selectedTime;
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();

  bool get isFormValid =>
      selectedClinic != null && selectedTime != null && selectedDate != null;

  List<String> getAvailableTimes() {
    List<String> times = [];
    for (int hour = 9; hour <= 17; hour++) {
      if (hour == 12) continue; // Skip the lunch break
      for (int minute = 0; minute < 60; minute += 30) {
        int formattedHour = hour % 12 == 0 ? 12 : hour % 12;
        String period = hour < 12 ? 'AM' : 'PM';
        String time =
            '${formattedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        times.add(time);
      }
    }
    return times;
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text =
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _scheduleAppointment() async {
    if (selectedClinic != null &&
        selectedTime != null &&
        selectedDate != null) {
      // Get current user ID
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle case where user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('You need to be logged in to schedule an appointment.')));
        return;
      }

      // Prepare the appointment data
      final newAppointment = {
        'patientId': user.uid,
        'clinic': selectedClinic!,
        'time': selectedTime!,
        'date':
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save appointment to Firestore
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .add(newAppointment);

        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Appointment Scheduled'),
              content: Text(
                'Clinic: ${newAppointment['clinic']}\n'
                'Time: ${newAppointment['time']}\n'
                'Date: ${newAppointment['date']}',
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Close the scheduling screen
                  },
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error scheduling appointment: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Appointment'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildDropdown(
                  hint: 'Select Polyclinic',
                  value: selectedClinic,
                  items: clinics,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClinic = newValue;
                    });
                  },
                ),
                SizedBox(height: 10),
                _buildDropdown(
                  hint: 'Select Time',
                  value: selectedTime,
                  items: getAvailableTimes(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTime = newValue;
                    });
                  },
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        hintText: 'Tap to select a date',
                        hintStyle: TextStyle(fontSize: 12),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: isFormValid ? _scheduleAppointment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFormValid ? Color(0xFF7165D6) : Colors.grey,
                    // Change color based on form validity
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Schedule Appointment',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        hint: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            hint,
            style: TextStyle(fontSize: 14),
          ),
        ),
        value: value,
        onChanged: onChanged,
        isExpanded: true,
        underline: SizedBox(),
        // Remove the underline
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(item),
            ),
          );
        }).toList(),
      ),
    );
  }
}
