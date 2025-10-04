import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasking/core/constants/constants.dart';
import 'package:tasking/core/models/category_model.dart';
import 'package:tasking/core/widgets/custom_button.dart';
import 'package:tasking/core/widgets/decorated_app_bar.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key, this.todo});
  final QueryDocumentSnapshot? todo;
  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  bool? isDone;
  DateTime? _selectedDate;
  String? _formattedDate;
  String? _formattedTime;
  TimeOfDay? _selectedTime;
  CategoryModel? selectedCategory;
  IconData? selectedIcon;
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
        selectedCategory = categories.firstWhere((category) {
          return category.icon.codePoint == widget.todo?['category'];
        });
        selectedIcon = selectedCategory?.icon;
      }
      if (widget.todo?['dueDate'] != null) {
        final dateFormat = DateFormat('yyyy-M-d');
        _selectedDate = dateFormat.parse(widget.todo?['dueDate']);
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
    } else {
      selectedCategory = categories[0];
      selectedIcon = categories[0].icon;
    }
    super.initState();
  }

  void _addTask() {
    if (widget.todo != null) {
      tasksCollection.doc(widget.todo?.id).update({
        'title': _taskTitleController.text.trim(),
        'dueDate': _formattedDate?.trim(),
        'dueTime': _formattedTime?.trim(),
        'category': selectedIcon?.codePoint,
        'notes': _noteTitleController.text.trim(),
      });
    } else {
      tasksCollection.add({
        'isDone': false,
        'title': _taskTitleController.text.trim(),
        'dueDate': _formattedDate?.trim(),
        'dueTime': _formattedTime?.trim(),
        'category': selectedIcon?.codePoint,
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
                            showRemoveTaskConfirmation();
                          },
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 40,
                          ),
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
                                    side: const BorderSide(color: Colors.grey),
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
                        children: [
                          GestureDetector(
                            onTap: () async {
                              CategoryModel? result = await showCategoryPicker(
                                context,
                              );
                              if (result != null) {
                                selectedCategory = result;
                                selectedIcon = result.icon;
                                setState(() {});
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                color: selectedCategory?.color,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  selectedIcon,
                                  size: 35,
                                  color: Color(0xFF4a3880),
                                ),
                              ),
                            ),
                          ),
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
            child: CustomButton(
              text: 'Save',
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  _addTask();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task saved successfully!')),
                  );
                  context.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<CategoryModel?> showCategoryPicker(BuildContext context) async {
    return showModalBottomSheet<CategoryModel>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, category),
                      child: Container(
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category.icon,
                          color: Colors.black87,
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showRemoveTaskConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          constraints: BoxConstraints(maxHeight: 0.25.sh),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  child: Icon(Icons.close),
                  onTap: () => context.pop(),
                ),
              ),
              Center(
                child: Text(
                  'Do you want to delete this task ?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          onTap: () {
                            context.pop();
                          },
                        ),
                      ),
                      5.horizontalSpace,
                      Expanded(
                        child: CustomButton(
                          text: 'Yes',
                          color: Colors.red,
                          onTap: () {
                            tasksCollection.doc(widget.todo?.id).delete();
                            context.go('/home');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextFormField _buildNewTaskTextField(TextEditingController controller) {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Required Field';
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
