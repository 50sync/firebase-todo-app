import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
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
  List<String> selectedTasksIds = [];
  bool isMultiSelect = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    log(fireAuthInstance.currentUser!.uid.toString());
    return BlocProvider(
      create: (context) =>
          TaskBloc(firestore: fireStoreInstance)..add(LoadTasks()),

      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          backgroundColor: Color(0xFF4a3880),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      fireStoreInstance.terminate();
                      await fireAuthInstance.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.red, size: 40),
                        10.horizontalSpace,
                        Text(
                          'Log Out',
                          style: TextStyle(fontSize: 32.sp, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFFf1f5f9),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Stack(children: [DecoratedAppBar(height: 0.3.sh)]),
                  Positioned.fill(
                    child: SafeArea(
                      child: BlocConsumer<TaskBloc, TaskState>(
                        listener: (context, state) {
                          if (state is TasksLoaded) {
                            final docs = state.docs;

                            setState(() {
                              unCompletedTasks = docs
                                  .where((doc) => doc['isDone'] == false)
                                  .toList();
                              completedTasks = docs
                                  .where((doc) => doc['isDone'] == true)
                                  .toList();
                              if (completedTasks.length == docs.length) {
                                _isCompletedTasksShown = true;
                              }
                            });
                          }
                        },
                        builder: (context, state) {
                          if (state is TaskInitial || state is TaskLoading) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (state is TaskError) {
                            return Center(
                              child: Text('Error: ${state.message}'),
                            );
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
                                                  context,
                                                ),
                                                if (index !=
                                                    unCompletedTasks.length - 1)
                                                  Divider(
                                                    height: 0,
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.5),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                      context,
                                                    ),
                                                    if (index !=
                                                        completedTasks.length -
                                                            1)
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            log('message');
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          child: Icon(
                            Icons.menu,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isMultiSelect == true)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              log('message');
                              setState(() {
                                isMultiSelect = false;
                                selectedTasksIds.clear();
                              });
                            },
                            child: Icon(
                              Icons.done_all,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomButton(
                text: isMultiSelect ? 'Delete' : 'Add New Task',
                color: isMultiSelect ? Colors.red : null,
                onTap: () async {
                  if (isMultiSelect) {
                    deleteSelectedTasks(selectedTasksIds);
                    setState(() {
                      isMultiSelect = false;
                    });
                  } else {
                    context.push('/addTask');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    QueryDocumentSnapshot todo,
    int index,
    BuildContext context,
  ) {
    // Use final for immutable variables
    bool isDone = todo['isDone'] ?? false;
    final bool isSelected = selectedTasksIds.contains(todo.id);

    final category = categories.firstWhere(
      (category) => category.icon.codePoint == todo['category'],
      orElse: () => categories.first, // Provide fallback
    );

    return StatefulBuilder(
      builder: (context, setTaskState) {
        return Material(
          key: ValueKey(todo.id), // Better to use todo.id for consistency
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          child: InkWell(
            onLongPress: () {
              setState(() {
                isMultiSelect = true;
                if (selectedTasksIds.contains(todo.id)) {
                  selectedTasksIds.remove(todo.id);
                  if (selectedTasksIds.isEmpty) {
                    isMultiSelect = false;
                  }
                } else {
                  selectedTasksIds.add(todo.id);
                }
              });
            },
            onTap: () {
              if (isMultiSelect) {
                // Toggle selection in multi-select mode
                setState(() {
                  if (selectedTasksIds.contains(todo.id)) {
                    selectedTasksIds.remove(todo.id);
                    if (selectedTasksIds.isEmpty) {
                      isMultiSelect = false;
                    }
                  } else {
                    selectedTasksIds.add(todo.id);
                  }
                });
              } else {
                // Normal tap behavior
                context.push('/addTask', extra: {'todo': todo});
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
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
                            color: const Color(0xFF4a3780),
                          ),
                        ),
                        5.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo['title'] ?? 'Untitled Task',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: isDone ? Colors.grey : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (todo['dueDate'] != null ||
                                  todo['dueTime'] != null)
                                Row(
                                  children: [
                                    if (todo['dueDate'] != null)
                                      Text(
                                        _formatDueDate(todo['dueDate'])!,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    if (todo['dueDate'] != null &&
                                        todo['dueTime'] != null)
                                      5.horizontalSpace,
                                    if (todo['dueTime'] != null)
                                      Text(
                                        todo['dueTime'],
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      side: const BorderSide(color: Colors.grey),
                      value: isMultiSelect ? isSelected : isDone,
                      onChanged: (newValue) {
                        if (newValue == null) return;

                        if (isMultiSelect) {
                          // Multi-select mode: toggle selection
                          setState(() {
                            if (newValue) {
                              selectedTasksIds.add(todo.id);
                            } else {
                              selectedTasksIds.remove(todo.id);
                            }
                          });
                        } else {
                          // Normal mode: toggle completion
                          // Update local state immediately for animation
                          setTaskState(() {
                            isDone = newValue;
                          });

                          if (newValue) {
                            AudioPlayer().play(AssetSource('check.mp3'));
                          }

                          // Update through BLoC
                          Future.delayed(Duration(milliseconds: 300), () {
                            if (context.mounted) {
                              context.read<TaskBloc>().add(
                                ToggleTaskCompletion(
                                  taskId: todo.id,
                                  isCompleted: newValue,
                                ),
                              );
                            }
                          });
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

  Future<void> deleteSelectedTasks(List<String> selectedTasksIds) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var id in selectedTasksIds) {
      final docRef = tasksCollection.doc(id);
      batch.delete(docRef);
    }

    // Commit all deletions at once
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task${selectedTasksIds.length > 1 ? 's' : ''} Deleted Successfully',
          ),
        ),
      );
      selectedTasksIds.clear();
    }
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
