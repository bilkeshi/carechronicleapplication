import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    // Manually provide the Firebase options with the updated credentials
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDNkdPkr7UoZXfHPNtg3xCujo9rG36abtY",
        appId: "1:799706608096:android:db73a6b023d8fa1a967b85",
        messagingSenderId: "799706608096",
        projectId: "wound-care-ai", // Updated project ID
        storageBucket:
            "wound-care-ai.firebasestorage.app", // Updated storage bucket
        authDomain: "wound-care-ai.firebaseapp.com", // Updated auth domain
      ),
    );

    // Listen to user state changes
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}
