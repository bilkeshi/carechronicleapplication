import 'package:care_chronicle_app/widgets/navbar_roots.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  String errorMessage = ''; // To show any error messages

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Sign in with email and password
        await _auth.signInWithEmailAndPassword(
          email: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );

        // If successful, navigate to the main page (NavBarRoots)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavBarRoots(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        // If there is an error, display the error message
        setState(() {
          errorMessage = e.message ?? 'An error occurred';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset("images/woundicon.jpg"),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Username (Email)",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your email';
                      }
                      // You can add additional email validation if needed
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Enter Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(iconPassword),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                            iconPassword = obscurePassword
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      } else if (val.length < 7) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                ),
                // Displaying error message (if any)
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7165D6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 40),
                      ),
                      onPressed: _login,
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7165D6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
