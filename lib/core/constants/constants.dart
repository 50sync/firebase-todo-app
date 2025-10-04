import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasking/core/models/category_model.dart';

final fireAuthInstance = FirebaseAuth.instance;

final List<CategoryModel> categories = [
  CategoryModel(icon: Icons.check, color: Color(0xFFdbecf6)),
  CategoryModel(icon: Icons.calendar_month_outlined, color: Color(0xFFdbecf6)),
  CategoryModel(icon: Icons.wb_sunny_outlined, color: Color(0xFFe7e2f3)),
  CategoryModel(icon: Icons.emoji_events_outlined, color: Color(0xFFfef5d3)),
];

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
