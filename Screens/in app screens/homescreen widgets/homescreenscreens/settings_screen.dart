import 'package:care_chronicle_app/Screens/in%20app%20screens/settings%20options/aboutus_screen.dart'; // Import your About Us screen
import 'package:care_chronicle_app/Screens/in%20app%20screens/settings%20options/general_screen.dart';
import 'package:care_chronicle_app/Screens/in%20app%20screens/settings%20options/notification_setting_screen.dart';
import 'package:care_chronicle_app/Screens/in%20app%20screens/settings%20options/privacy_setting_screen.dart';
import 'package:care_chronicle_app/Screens/main%20screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../settings options/profile_setting_screen.dart';

class SettingsScreen extends StatelessWidget {
  Future<Map<String, String>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    String name = "No name available";
    String email = "No email available";

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('patients') // Use the correct collection name
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          name = userDoc['name'] ?? user.displayName ?? "No name available";
        }
        email = user.email ?? "No email available";
      } catch (e) {
        print("Error retrieving user info: $e");
      }
    }
    return {'name': name, 'email': email};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 45, left: 18, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            FutureBuilder<Map<String, String>>(
              future: _getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("images/your_image.jpg"),
                    ),
                    title: Text(
                      "Loading...",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 25,
                      ),
                    ),
                    subtitle: Text("Loading email..."),
                  );
                } else if (snapshot.hasError) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("images/your_image.jpg"),
                    ),
                    title: Text(
                      "Error retrieving info",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 25,
                      ),
                    ),
                    subtitle: Text("Error loading email"),
                  );
                } else if (snapshot.hasData) {
                  String name = snapshot.data?['name'] ?? "Patient Name";
                  String email =
                      snapshot.data?['email'] ?? "No email available";
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("images/your_image.jpg"),
                    ),
                    title: Text(
                      name, // Display the user's name
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 25,
                      ),
                    ),
                    subtitle: Text(email), // Display the user's email
                  );
                }
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("images/your_image.jpg"),
                  ),
                  title: Text(
                    "Patient Name", // Fallback text if no data
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                  ),
                  subtitle: Text("No email available"),
                );
              },
            ),
            Divider(height: 40),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileSettingsScreen()),
                );
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.person,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
              title: Text(
                "Profile",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsScreen()),
                );
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.deepPurple,
                  size: 32,
                ),
              ),
              title: Text(
                "Notification",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacySettingsScreen()),
                );
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.indigo,
                  size: 32,
                ),
              ),
              title: Text(
                "Privacy",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GeneralSettingsScreen()),
                );
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_suggest_outlined,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              title: Text(
                "General",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsScreen()),
                );
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              title: Text(
                "About Us",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
            Divider(height: 40),
            ListTile(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_outlined,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),
              title: Text(
                "Log Out",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
