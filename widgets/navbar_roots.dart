import 'package:flutter/material.dart';

import '../Screens/in app screens/homescreen widgets/Wound Capture AI/assessment_provider.dart';
import '../Screens/in app screens/homescreen widgets/Wound Capture AI/tracking_screen.dart';
import '../Screens/in app screens/homescreen widgets/homescreenscreens/appointment_screen.dart';
import '../Screens/in app screens/homescreen widgets/homescreenscreens/home_screen.dart';
import '../Screens/in app screens/homescreen widgets/homescreenscreens/reminders_screen.dart';
import '../Screens/in app screens/homescreen widgets/homescreenscreens/settings_screen.dart';

class NavBarRoots extends StatefulWidget {
  final List<Assessment>? initialAssessments;

  const NavBarRoots({Key? key, this.initialAssessments}) : super(key: key);

  @override
  State<NavBarRoots> createState() => _NavBarRootsState();
}

class _NavBarRootsState extends State<NavBarRoots> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Directly instantiate the provider without using `Provider.of`
      final provider = AssessmentProvider();
      await provider.loadAssessmentsFromFirestore();
      setState(() {}); // Ensure the UI updates after loading
    });
  }

  List<Widget> get _screens => [
        HomeScreen(),
        ReminderScreen(),
        AppointmentScreen(),
        SettingsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.initialAssessments != null &&
            widget.initialAssessments!.isNotEmpty) {
          // Ensure assessments are saved before popping
          final provider = AssessmentProvider();
          await provider.addNewAssessments(widget.initialAssessments!);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF7165D6),
          unselectedItemColor: Colors.black26,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Reminders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Appointments",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
