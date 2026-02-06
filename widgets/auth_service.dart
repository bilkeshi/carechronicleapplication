// auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('patients').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    required String dob,
    required String gender,
    String? email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final updates = {
          'name': name,
          'dob': dob,
          'gender': gender,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (email != null && email != user.email) {
          await user.verifyBeforeUpdateEmail(email);
          updates['email'] = email;
        }

        await _firestore.collection('patients').doc(user.uid).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }
}
