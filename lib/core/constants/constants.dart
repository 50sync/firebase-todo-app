import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasking/core/models/category_model.dart';

final fireAuthInstance = FirebaseAuth.instance;
final fireStoreInstance = FirebaseFirestore.instance;

final List<CategoryModel> categories = [
  CategoryModel(icon: Icons.check, color: Color(0xFFdbecf6)), // Tasks
  CategoryModel(
    icon: Icons.calendar_month_outlined,
    color: Color(0xFFdbecf6),
  ), // Schedule
  CategoryModel(
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFFe7e2f3),
  ), // Morning
  CategoryModel(
    icon: Icons.emoji_events_outlined,
    color: Color(0xFFfef5d3),
  ), // Goals
  CategoryModel(
    icon: Icons.fitness_center_outlined,
    color: Color(0xFFe3f9e5),
  ), // Fitness
  CategoryModel(icon: Icons.book_outlined, color: Color(0xFFfff0f0)), // Study
  CategoryModel(icon: Icons.work_outline, color: Color(0xFFf1f8ff)), // Work
  CategoryModel(
    icon: Icons.shopping_cart_outlined,
    color: Color(0xFFfff5e6),
  ), // Shopping
  CategoryModel(
    icon: Icons.favorite_border,
    color: Color(0xFFfdeef3),
  ), // Health / Self-care
  CategoryModel(icon: Icons.home_outlined, color: Color(0xFFe9f6ec)), // Home
  CategoryModel(
    icon: Icons.nightlight_outlined,
    color: Color(0xFFe8eaf6),
  ), // Night Routine
  CategoryModel(
    icon: Icons.travel_explore_outlined,
    color: Color(0xFFe3f2fd),
  ), // Travel
  CategoryModel(
    icon: Icons.music_note_outlined,
    color: Color(0xFFfff3e0),
  ), // Entertainment
  CategoryModel(
    icon: Icons.savings_outlined,
    color: Color(0xFFf0f4c3),
  ), // Finance
  CategoryModel(
    icon: Icons.brush_outlined,
    color: Color(0xFFfce4ec),
  ), // Creativity
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
