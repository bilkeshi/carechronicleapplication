import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../scheduling_screen.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int _buttonIndex = 0;
  Map<int, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: const Text(
                "Appointments",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTabButtons(),
            const SizedBox(height: 30),
            _buildAppointmentsList(),
            if (_buttonIndex == 0)
              Padding(
                padding: const EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () => _navigateToSchedulingScreen(context),
                  child: const Text("Schedule Appointment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 25),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Navigate to SchedulingScreen and get the result
  void _navigateToSchedulingScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SchedulingScreen()),
    );

    if (result != null) {
      // Handle the scheduling result here
      setState(() {
        // You can add the result to the list or handle as needed
      });
    }
  }

  // Tab buttons for navigating between different appointment states
  Widget _buildTabButtons() {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 3; i++)
            _buildTabButton(i, ["Upcoming", "Completed", "Missed"][i]),
        ],
      ),
    );
  }

  // Tab button widget for state selection
  Widget _buildTabButton(int index, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _buttonIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: _buttonIndex == index
              ? const Color(0xFF7165D6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _buttonIndex == index
                ? Colors.transparent
                : const Color(0xFF7165D6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _buttonIndex == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // List to display appointments based on selected tab
  Widget _buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              _buttonIndex == 0
                  ? "No upcoming appointments"
                  : _buttonIndex == 1
                      ? "No completed appointments"
                      : "No missed appointments",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final appointmentData = snapshot.data!.docs[index];
            final appointmentId = appointmentData.id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    title: Text(
                      appointmentData['clinic'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${appointmentData['time']} - ${appointmentData['date']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onTap: () {
                      setState(() {
                        _expanded[index] = !_expanded.containsKey(index)
                            ? true
                            : !_expanded[index]!;
                      });
                    },
                  ),
                  if (_expanded[index] == true)
                    _buildExpandableOptions(index, appointmentId),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Expandable options for each appointment
  Widget _buildExpandableOptions(int index, String appointmentId) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              _navigateToSchedulingScreen(context);
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Reschedule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showCancelConfirmationDialog(index, appointmentId);
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to confirm cancellation of an appointment
  void _showCancelConfirmationDialog(int index, String appointmentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel Appointment"),
          content:
              const Text("Are you sure you want to cancel this appointment?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                // Remove the appointment from Firestore using its ID
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(appointmentId) // Use the appointmentId from Firestore
                    .delete();

                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
