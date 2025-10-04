import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:tasking/core/constants/constants.dart';
import 'package:tasking/core/models/category_model.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final List<CategoryModel> _categories = [
    CategoryModel(
      icon: Icons.calendar_month_outlined,
      color: Color(0xFFdbecf6),
      type: 'calendar',
    ),
    CategoryModel(
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFe7e2f3),
      type: 'sun',
    ),
    CategoryModel(
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFfef5d3),
      type: 'trophy',
    ),
  ];
  int? selectedIndex;
  DateTime? _selectedDate;
  String? _formattedDate;
  String? _formattedTime;
  TimeOfDay? _selectedTime;
  final TextEditingController _taskTitleController = TextEditingController();
  void _addTask() {
    todosCollection.add({
      'isDone': false,
      'title': _taskTitleController.text,
      'dueDate': _formattedDate,
      'dueTime': _formattedTime,
      'category': _categories[selectedIndex!].type,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf1f5f9),
      body: Column(
        children: [
          Container(
            height: 0.15.sh,
            clipBehavior: Clip.none,
            width: double.infinity,
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
                SafeArea(
                  child: Row(
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
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Add New Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    _buildNewTaskTextField(_taskTitleController),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),

                    ...List.generate(_categories.length, (index) {
                      final isSelected = selectedIndex == index; // 🟢 هنا بيشيك

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
                            color: _categories[index].color,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              _categories[index].icon,
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
                              DateTime? selectedDate = await showDatePicker(
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
                                  color: Colors.grey.withValues(alpha: 0.5),
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
                          GestureDetector(
                            onTap: () async {
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime ?? TimeOfDay.now(),
                              );
                              if (selectedTime != null && context.mounted) {
                                _selectedTime = selectedTime;
                                _formattedTime = _selectedTime!.format(context);
                                setState(() {});
                              }
                              log(_selectedTime.toString());
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.5),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xFF4a3780)),
              onPressed: () {
                if (selectedIndex != null) {
                  _addTask();
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Category Required')));
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

  TextField _buildNewTaskTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
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
