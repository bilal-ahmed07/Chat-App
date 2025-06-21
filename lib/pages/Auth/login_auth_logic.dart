import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final userDoc = await _firestore
          .collection('usernames')
          .doc(username)
          .get();

      if (!userDoc.exists) {
        return 'Username not found';
      }

      final email = userDoc['email'];

      if (email == null || email.isEmpty) {
        return 'Email not found for this username';
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email format';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later';
        default:
          return e.message ?? 'Login failed';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<String> loginUserWithQuery({
    required String username,
    required String password,
  }) async {
    try {
      final query = await _firestore
          .collection('usernames')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return 'Username not found';
      }

      final userDoc = query.docs.first;
      final email = userDoc['email'];

      if (email == null || email.isEmpty) {
        return 'Email not found for this username';
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email format';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later';
        default:
          return e.message ?? 'Login failed';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }
}