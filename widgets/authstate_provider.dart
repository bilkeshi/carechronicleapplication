import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStateProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  // Listen to changes in the authentication state
  AuthStateProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // Check if user is logged in
  bool get isLoggedIn => _user != null;

  // Optionally, implement a method to log the user out
  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
