import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasking/core/constants/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf1f5f9),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  clipBehavior: Clip.none,
                  width: double.infinity,
                  height: 0.3.sh,
                  decoration: BoxDecoration(color: Color(0xFF4a3780)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SvgPicture.asset('assets/ellipse1.svg'),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: SvgPicture.asset('assets/ellipse2.svg'),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: SafeArea(
                    child: StreamBuilder(
                      stream: todosCollection.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No tasks yet'));
                        }

                        final docs = snapshot.data!.docs;

                        final tasksToDoList = docs
                            .where((doc) => doc['isDone'] == false)
                            .toList();
                        final completedTasks = docs
                            .where((doc) => doc['isDone'] == true)
                            .toList();

                        log('Tasks count: ${docs.length}');

                        return SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: [
                                    Text(
                                      _currentDate,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    20.verticalSpace,
                                    Text(
                                      'My Todo List',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 32.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              20.verticalSpace,

                              // 🟢 To Do tasks
                              if (tasksToDoList.isNotEmpty)
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  transitionBuilder: (child, animation) {
                                    final offsetAnimation = Tween<Offset>(
                                      begin: Offset(1.0, 0.0), // يبدأ من اليمين
                                      end: Offset.zero,
                                    ).animate(animation);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Column(
                                      children: [
                                        ...List.generate(
                                          tasksToDoList.length,
                                          (index) => Column(
                                            children: [
                                              _buildTaskItem(
                                                tasksToDoList[index],
                                                index,
                                              ),
                                              if (index !=
                                                  tasksToDoList.length - 1)
                                                Divider(
                                                  height: 0,
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // 🟣 Completed tasks
                              if (completedTasks.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 400),
                                  transitionBuilder: (child, animation) {
                                    final offsetAnimation = Tween<Offset>(
                                      begin: Offset(1.0, 0.0), // يبدأ من اليمين
                                      end: Offset.zero,
                                    ).animate(animation);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Column(
                                      children: List.generate(
                                        completedTasks.length,
                                        (index) => Column(
                                          children: [
                                            _buildTaskItem(
                                              completedTasks[index],
                                              index,
                                            ),
                                            if (index !=
                                                completedTasks.length - 1)
                                              Divider(
                                                height: 0,
                                                color: Colors.grey.withValues(
                                                  alpha: 0.5,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xFF4a3780)),
              onPressed: () {
                context.push('/addTask');
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Add New Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(QueryDocumentSnapshot todo, int index) {
    final isDoneNotifier = ValueNotifier<bool>(todo['isDone'] ?? false);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          context.push('/insideTask', extra: {'todo': todo});
        },
        child: ValueListenableBuilder<bool>(
          valueListenable: isDoneNotifier,
          builder: (context, value, child) {
            return Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        key: ValueKey(isDoneNotifier.value),
                        decoration: BoxDecoration(
                          color: value ? Colors.green : Colors.cyan,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          switch (todo['category']) {
                            'calendar' => Icons.calendar_month_outlined,
                            'sun' => Icons.wb_sunny_outlined,
                            'trophy' => Icons.emoji_events_outlined,
                            _ => Icons.check,
                          },
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      5.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              decoration: value
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: Colors.grey,

                              color: value ? Colors.grey : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              if (todo['dueDate'] != null)
                                Text(
                                  '${_formatDueDate(todo['dueDate'])} ${todo['dueTime']}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                    decoration: value
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      side: BorderSide(color: Colors.grey),
                      value: value,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          isDoneNotifier.value = newValue;

                          Future.delayed(Duration(milliseconds: 400), () {
                            todosCollection.doc(todo.id).update({
                              'isDone': newValue,
                            });
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDueDate(String dueDate) {
    try {
      final date = DateTime.parse(dueDate);
      return DateFormat('yyy-MM-d').format(date);
    } catch (e) {
      return dueDate;
    }
  }
}
