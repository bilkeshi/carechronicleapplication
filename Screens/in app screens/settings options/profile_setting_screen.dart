import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _dobController =
      TextEditingController(); // DOB controller
  String _gender = "Male"; // Default gender
  String profilePicUrl =
      'https://www.example.com/default-profile-pic.jpg'; // Default image

  // Fetch user data from Firebase
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('patients') // Updated collection name
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Populate the fields with user data from Firestore
          setState(() {
            _nameController.text = userDoc['name'] ?? 'No name available';
            _emailController.text = userDoc['email'] ?? user.email ?? '';
            _dobController.text = userDoc['dob'] ?? ''; // Date of Birth
            _gender = userDoc['gender'] ?? 'Male'; // Gender
            profilePicUrl = userDoc['profilePicUrl'] ??
                'https://www.example.com/default-profile-pic.jpg'; // Fallback image URL
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when screen is loaded
  }

  // Method to update the profile in Firestore
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('patients') // Updated collection name
              .doc(user.uid)
              .update({
            'name': _nameController.text,
            'email': _emailController.text,
            'dob': _dobController.text,
            'gender': _gender,
            // 'profilePicUrl': newProfilePicUrl, // You can handle profile picture update similarly
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  // Method to change the profile picture (dummy placeholder for actual logic)
  Future<void> _changeProfilePicture() async {
    setState(() {
      profilePicUrl =
          'https://www.example.com/updated-profile-pic.jpg'; // Example updated URL
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: GestureDetector(
                  onTap: _changeProfilePicture,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profilePicUrl),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
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
              SizedBox(height: 15),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Date of Birth Field
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _gender,
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.accessibility),
                ),
                items: <String>['Male', 'Female']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7165D6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
