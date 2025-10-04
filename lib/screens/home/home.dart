import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasking/core/bloc/bloc/task_bloc.dart';
import 'package:tasking/core/constants/constants.dart';
import 'package:tasking/core/widgets/custom_button.dart';
import 'package:tasking/core/widgets/decorated_app_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
  bool _isCompletedTasksShown = false;
  late List<QueryDocumentSnapshot> completedTasks;
  late List<QueryDocumentSnapshot> unCompletedTasks;

  @override
  void initState() {
    super.initState();
    // Load tasks when the screen initializes
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    log(fireAuthInstance.currentUser!.uid.toString());
    return Scaffold(
      backgroundColor: Color(0xFFf1f5f9),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                DecoratedAppBar(height: 0.3.sh),
                Positioned.fill(
                  child: SafeArea(
                    child: BlocConsumer<TaskBloc, TaskState>(
                      listener: (context, state) {
                        if (state is TasksLoaded) {
                          final docs = state.docs;

                          unCompletedTasks = docs
                              .where((doc) => doc['isDone'] == false)
                              .toList();
                          completedTasks = docs
                              .where((doc) => doc['isDone'] == true)
                              .toList();

                          if (completedTasks.length == docs.length) {
                            setState(() {
                              _isCompletedTasksShown = true;
                            });
                          }
                        }
                      },
                      builder: (context, state) {
                        if (state is TaskInitial || state is TaskLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (state is TaskError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }

                        if (state is TasksLoaded) {
                          final docs = state.docs;

                          return SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    children: [
                                      20.verticalSpace,

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
                                if (docs.isEmpty)
                                  SizedBox(
                                    height: 0.7.sh,
                                    child: Center(
                                      child: Text(
                                        'No tasks yet',
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  20.verticalSpace,
                                // 🟢 To Do tasks
                                if (unCompletedTasks.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Column(
                                      children: [
                                        ...List.generate(
                                          unCompletedTasks.length,
                                          (index) => Column(
                                            children: [
                                              _buildTaskItem(
                                                unCompletedTasks[index],
                                                index,
                                              ),
                                              if (index !=
                                                  unCompletedTasks.length - 1)
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

                                // 🟣 Completed tasks
                                if (completedTasks.isNotEmpty) ...[
                                  if (completedTasks.length != docs.length)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isCompletedTasksShown =
                                              !_isCompletedTasksShown;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            _isCompletedTasksShown
                                                ? Icons.keyboard_arrow_down
                                                : Icons.keyboard_arrow_right,
                                          ),
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
                                        ],
                                      ),
                                    ),
                                  if (_isCompletedTasksShown)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
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
                                                      color: Colors.grey
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ],
                            ),
                          );
                        }

                        return Center(child: Text('Unknown state'));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              text: 'Add New Task',
              onTap: () => context.push('/addTask'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(QueryDocumentSnapshot todo, int index) {
    final isDoneNotifier = ValueNotifier<bool>(todo['isDone'] ?? false);
    final category = categories.firstWhere((category) {
      return category.icon.codePoint == todo['category'];
    });
    return ValueListenableBuilder<bool>(
      valueListenable: isDoneNotifier,
      builder: (context, value, child) {
        return Material(
          key: UniqueKey(),
          color: Colors.white,
          child: InkWell(
            onTap: () {
              context.push('/addTask', extra: {'todo': todo});
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          category.icon,
                          size: 30,
                          color: Color(0xFF4a3780),
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
                              color: value ? Colors.grey : Colors.black,
                            ),
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              if (todo['dueDate'] != null)
                                Text(
                                  _formatDueDate(todo['dueDate'])!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                    decoration: value
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              if (todo['dueTime'] != null)
                                Text(
                                  todo['dueTime'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                    decoration: value
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
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
                      side: const BorderSide(color: Colors.grey),
                      value: value,
                      onChanged: (newValue) async {
                        if (newValue != null) {
                          // Update local state immediately for animation
                          isDoneNotifier.value = newValue;
                          // Update database through BLoC
                          if (context.mounted) {
                            context.read<TaskBloc>().add(
                              ToggleTaskCompletion(
                                taskId: todo.id,
                                isCompleted: newValue,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _formatDueDate(String? dueDate) {
    try {
      if (dueDate != null) {
        final date = DateTime.parse(dueDate);

        return DateFormat('yyy-MM-d').format(date);
      } else {
        return null;
      }
    } catch (e) {
      return dueDate;
    }
  }
}
