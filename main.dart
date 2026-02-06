import 'package:care_chronicle_app/Screens/main%20screens/welcome_screen.dart';
import 'package:care_chronicle_app/widgets/navbar_roots.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Screens/in app screens/homescreen widgets/Wound Capture AI/assessment_provider.dart';
import 'Screens/main screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDNkdPkr7UoZXfHPNtg3xCujo9rG36abtY",
      appId: "1:799706608096:android:db73a6b023d8fa1a967b85",
      messagingSenderId: "799706608096",
      projectId: "wound-care-ai",
      storageBucket: "wound-care-ai.firebasestorage.app",
      authDomain: "wound-care-ai.firebaseapp.com",
    ),
  );

  final assessmentProvider = AssessmentProvider();
  await assessmentProvider.loadAssessmentsFromFirestore();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
        // Check if the user is logged in
        future: FirebaseAuth.instance.currentUser?.reload().then((_) {
          return FirebaseAuth.instance.currentUser;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // While checking, show loading spinner
          }
          if (snapshot.hasData && snapshot.data != null) {
            return NavBarRoots(); // Show HomeScreen if logged in
          } else {
            return WelcomeScreen(); // Show WelcomeScreen if not logged in
          }
        },
      ),
    );
  }
}
