import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final fireAuthInstance = FirebaseAuth.instance;

CollectionReference<Map<String, dynamic>> get tasksCollection {
  final user = fireAuthInstance.currentUser;
  if (user == null) {
    throw Exception('User not logged in');
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('tasks');
}