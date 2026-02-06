import 'package:care_chronicle_app/widgets/navbar_roots.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  bool _loading = true;
  bool get loading => _loading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
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

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        //addPatientRecord();
      } else {
        _loggedIn = false;
      }
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> addPatientRecord({String? dob, String? gender}) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Future.value();

    return FirebaseFirestore.instance
        .collection('patients')
        .doc(user.uid)
        .set(<String, dynamic>{
      'name': user.displayName,
      'email': user.email,
      'dob': dob,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String dob,
    required String gender,
  }) async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(userCredential.user?.uid)
          .set({
        'email': email,
        'name': name,
        'dob': dob,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for that email';
      case 'user-not-found':
        return 'No user found for that email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'The email address is badly formatted';
      default:
        return 'An error occurred during authentication';
    }
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Female';
  bool _obscurePassword = true;

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime twelveYearsAgo =
        now.subtract(const Duration(days: 365 * 12));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: twelveYearsAgo,
      firstDate:
          DateTime(1900), // Set the start of the date range to 10 years ago
      lastDate:
          twelveYearsAgo, // Keep the current date as the last available date
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ApplicationState>(builder: (context, appState, _) {
        if (appState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("images/woundicon.jpg"),
                const SizedBox(height: 20),
                if (appState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      appState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Female', 'Male'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGender = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7165D6),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await appState.signUp(
                        email: _emailController.text,
                        password: _passwordController.text,
                        name: _nameController.text,
                        dob: _dobController.text,
                        gender: _selectedGender,
                      );

                      print(
                          'Sign-up completed, logged in: ${appState.loggedIn}');

                      if (appState.loggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NavBarRoots()),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Color(0xFF7165D6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
