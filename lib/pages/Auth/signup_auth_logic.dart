import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static Future<String?> signUpUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String dpUrl,
  }) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      final existing = await firestore.collection('usernames').doc(username).get();
      if (existing.exists) {
        return "Username already taken";
      }

      final userCred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      await firestore.collection('usernames').doc(username).set({
        'email': email,
        'createdAt': Timestamp.now(),
      });

      await firestore.collection('users').doc(username).set({
        'uid': uid,
        'username': username,
        'name': name,
        'email': email,
        'dp': dpUrl,
        'friends': [],
        'friendRequests': {},
        'createdAt': Timestamp.now(),
      });

      return null; 

    } catch (e) {
      SnackBar(content: Text("Signup error"),);
      return e.toString();
    }
  }
}
