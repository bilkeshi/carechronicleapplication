import 'package:care_chronicle_app/Screens/in%20app%20screens/woundtypes%20screens/wound_dressing_screen.dart';
import 'package:flutter/material.dart';

import '../../woundtypes screens/diabetic_screen.dart';
import '../../woundtypes screens/pressure_screen.dart';
import '../../woundtypes screens/venous_screen.dart';
import '../Wound Capture AI/capturing_screen.dart';
import '../Wound Capture AI/tracking_screen.dart';
import '../chatbot_screen.dart';
import '../pharmancy_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List woundtypes = ["Diabetic", "Pressure", "Venous"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              "images/logo.png",
              fit: BoxFit.contain,
              height: 35,
            ),
            SizedBox(width: 10),
            Text("Home"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hello Patient",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.message_outlined),
                        color: Colors.teal,
                        iconSize: 30,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatbotScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage("images/avatar.png"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF7165D6),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                color: Color(0xFF7165D6),
                                size: 35,
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "Wound Care",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "New Wound",
                              style: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PharmacyScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFFF0EEFA),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.health_and_safety_outlined,
                                color: Color(0xFF7165D6),
                                size: 35,
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "Pharmancy",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Wound Care Products",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackingScreen(
                        assessments: [],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up, // Icon for tracking
                            color: Colors.red,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Wound Care Tracking",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Track your wounds and recovery progress.",
                        style: TextStyle(
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 10),
                      Image.asset("images/progress.png"),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "CareChronicle Learn",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(
              height: 70,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: woundtypes.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (woundtypes[index] == "Diabetic") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiabeticWoundsPage(),
                          ),
                        );
                      }
                      if (woundtypes[index] == "Pressure") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PressureWoundsPage(),
                          ),
                        );
                      }
                      if (woundtypes[index] == "Venous") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VenousWoundsPage(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          woundtypes[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WoundDressingScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: Color(0xFF7165D6),
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Wound Dressing",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
