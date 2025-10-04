import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasking/core/constants/constants.dart';
import 'package:tasking/core/models/category_model.dart';
import 'package:tasking/core/widgets/decorated_app_bar.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key, this.todo});
  final QueryDocumentSnapshot? todo;
  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  bool? isDone;
  int? selectedIndex;
  DateTime? _selectedDate;
  String? _formattedDate;
  String? _formattedTime;
  TimeOfDay? _selectedTime;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();

  @override
  void initState() {
    isDone = widget.todo?['isDone'];
    if (widget.todo != null) {
      if (widget.todo?['title'] != null) {
        _taskTitleController.text = widget.todo?['title'];
      }
      if (widget.todo?['category'] != null) {
        selectedIndex = categories.indexWhere((category) {
          return category.type == widget.todo?['category'];
        });
      }
      if (widget.todo?['dueDate'] != null) {
        _selectedDate = DateTime.parse(widget.todo?['dueDate']);
        _formattedDate = widget.todo?['dueDate'];
      }
      if (widget.todo?['dueTime'] != null) {
        DateTime dateTime = DateFormat('h:mm a').parse(widget.todo?['dueTime']);
        _selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        _formattedTime = widget.todo?['dueTime'];
      }
      if (widget.todo?['notes'] != null) {
        _noteTitleController.text = widget.todo?['notes'];
      }
    }
    super.initState();
  }

  void _addTask() {
    if (widget.todo != null) {
      tasksCollection.doc(widget.todo?.id).update({
        'title': _taskTitleController.text.trim(),
        'dueDate': _formattedDate?.trim(),
        'dueTime': _formattedTime?.trim(),
        'category': categories[selectedIndex!].type.trim(),
        'notes': _noteTitleController.text.trim(),
      });
    } else {
      tasksCollection.add({
        'isDone': false,
        'title': _taskTitleController.text.trim(),
        'dueDate': _formattedDate?.trim(),
        'dueTime': _formattedTime?.trim(),
        'category': categories[selectedIndex!].type.trim(),
        'notes': _noteTitleController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf1f5f9),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedAppBar(height: 0.15.sh),
              SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.close, size: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Add New Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18.sp,
                      ),
                    ),
                    if (widget.todo != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            tasksCollection.doc(widget.todo?.id).delete();
                            context.pop();
                          },
                          icon: Icon(Icons.delete, color: Colors.red, size: 40),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    spacing: 20,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Task Title',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Form(
                                  key: _formKey,
                                  child: _buildNewTaskTextField(
                                    _taskTitleController,
                                  ),
                                ),
                              ),
                              if (widget.todo != null)
                                Transform.scale(
                                  scale: 1.5,
                                  child: Checkbox(
                                    value: isDone ?? false,
                                    onChanged: (value) {
                                      tasksCollection
                                          .doc(widget.todo?.id)
                                          .update({'isDone': value});
                                      setState(() {
                                        isDone = value;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),

                          ...List.generate(categories.length, (index) {
                            final isSelected =
                                selectedIndex == index; // 🟢 هنا بيشيك

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                                log(selectedIndex.toString());
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected == false
                                        ? Colors.white
                                        : Color(0xFF4a3880),
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                  color: categories[index].color,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    categories[index].icon,
                                    size: 35,
                                    color: Color(0xFF4a3780),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date'),
                                GestureDetector(
                                  onTap: () async {
                                    DateTime? selectedDate =
                                        await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2200),
                                        );
                                    if (selectedDate != null) {
                                      _selectedDate = selectedDate;
                                      _formattedDate = DateFormat(
                                        'yyy-MM-d',
                                      ).format(_selectedDate!);
                                      setState(() {});
                                    }
                                    log(_selectedDate.toString());
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _formattedDate != null
                                                ? _formattedDate!
                                                : 'Date',
                                          ),
                                          Spacer(),
                                          Icon(Icons.calendar_month_outlined),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Time'),
                                IgnorePointer(
                                  ignoring: _selectedDate != null
                                      ? false
                                      : true,
                                  child: GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? selectedTime =
                                          await showTimePicker(
                                            context: context,
                                            initialTime:
                                                _selectedTime ??
                                                TimeOfDay.now(),
                                          );
                                      if (selectedTime != null &&
                                          context.mounted) {
                                        _selectedTime = selectedTime;
                                        _formattedTime = _selectedTime!.format(
                                          context,
                                        );
                                        setState(() {});
                                      }
                                      log(_selectedTime.toString());
                                    },
                                    child: Container(
                                      foregroundDecoration:
                                          _selectedDate == null
                                          ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.grey.withValues(
                                                alpha: 0.4,
                                              ),
                                            )
                                          : null,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: Colors.grey.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),

                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              _formattedTime != null
                                                  ? _formattedTime!
                                                  : 'Time',
                                            ),
                                            Spacer(),
                                            Icon(Icons.access_time_outlined),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 0.25.sh,
                        child: TextField(
                          controller: _noteTitleController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Notes',
                            hintStyle: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          textAlignVertical: TextAlignVertical.top,
                          maxLines: null,
                          expands: true,
                        ),
                      ),
                    ],
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
                if (_formKey.currentState!.validate()) {
                  if (selectedIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Category Required')),
                    );
                  } else {
                    _addTask();
                    context.pop();
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Save',
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

  TextFormField _buildNewTaskTextField(TextEditingController controller) {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Required Fiedl';
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: 'Task Title',
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }
}
