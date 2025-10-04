import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasking/core/constants/constants.dart';

class InsideTask extends StatelessWidget {
  const InsideTask({super.key, required this.todo});
  final QueryDocumentSnapshot todo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: IconButton(
              onPressed: () {
                todosCollection.doc(todo.id).delete();
                context.pop();
              },
              icon: Icon(Icons.delete, color: Colors.red, size: 60),
            ),
          ),
        ],
      ),
    );
  }
}
