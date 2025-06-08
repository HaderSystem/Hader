// this page helps admin to manage courses, create courses and edit current courses

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageCoursesView extends StatefulWidget {
  const ManageCoursesView({super.key});

  @override
  State<ManageCoursesView> createState() => _ManageCoursesViewState();
}

class _ManageCoursesViewState extends State<ManageCoursesView> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> courses = [];
  Map<String, String> teacherNames = {};
  final List<String> _weekDays = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
  ];
  List<String> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadTeachers();
    await _loadCourses();
  }

  Future<void> _loadTeachers() async {
    final res = await supabase.from('teachers').select('id, name');
    final list = List<Map<String, dynamic>>.from(res);
    teacherNames = {
      for (var t in list) t['id']: t['name'],
    };
  }

  Future<void> _loadCourses() async {
    final res = await supabase
        .from('courses')
        .select(
            'id, name, start_date, end_date, start_time, end_time, lecture_days, teacher_id, student_courses(student_id)')
        .order('start_date');

    if (!mounted) return;
    setState(() {
      courses = List<Map<String, dynamic>>.from(res);
    });
  }

  void _showCourseDialog({Map<String, dynamic>? course}) {
    final nameController = TextEditingController(text: course?['name']);
    final startDateController =
        TextEditingController(text: course?['start_date'] ?? '');
    final endDateController =
        TextEditingController(text: course?['end_date'] ?? '');
    final startTimeController =
        TextEditingController(text: course?['start_time'] ?? '');
    final endTimeController =
        TextEditingController(text: course?['end_time'] ?? '');
    String? selectedTeacherId = course?['teacher_id'];

    showDialog(
      context: context,
      builder: (context) {
        _selectedDays = [...(course?['lecture_days']?.split(', ') ?? [])];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title:
                  Text(course == null ? 'add_course'.tr() : 'edit_course'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          InputDecoration(labelText: 'course_name'.tr()),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedTeacherId,
                      decoration: InputDecoration(labelText: 'teacher'.tr()),
                      items: teacherNames.entries
                          .map((e) => DropdownMenuItem<String>(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: (val) {
                        selectedTeacherId = val;
                      },
                    ),
                    TextField(
                      controller: startDateController,
                      readOnly: true,
                      decoration:
                          InputDecoration(labelText: 'start_date'.tr()),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          startDateController.text =
                              picked.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                    TextField(
                      controller: endDateController,
                      readOnly: true,
                      decoration:
                          InputDecoration(labelText: 'end_date'.tr()),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          endDateController.text =
                              picked.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                    TextField(
                      controller: startTimeController,
                      readOnly: true,
                      decoration:
                          InputDecoration(labelText: 'start_time'.tr()),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          startTimeController.text = picked.format(context);
                        }
                      },
                    ),
                    TextField(
                      controller: endTimeController,
                      readOnly: true,
                      decoration:
                          InputDecoration(labelText: 'end_time'.tr()),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          endTimeController.text = picked.format(context);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'lecture_days'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: _weekDays.map((day) {
                        return CheckboxListTile(
                          value: _selectedDays.contains(day),
                          title: Text(day.tr()),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? selected) {
                            setStateDialog(() {
                              if (selected == true) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final startDate = startDateController.text.trim();
                    final endDate = endDateController.text.trim();
                    final startTime = startTimeController.text.trim();
                    final endTime = endTimeController.text.trim();
                    final lectureDays = _selectedDays.join(', ');

                    if (name.isEmpty || selectedTeacherId == null) {
                      print('⛔️ Missing required fields!');
                      return;
                    }

                    final data = {
                      'name': name,
                      'start_date': startDate,
                      'end_date': endDate,
                      'start_time': startTime,
                      'end_time': endTime,
                      'lecture_days': lectureDays,
                      'teacher_id': selectedTeacherId,
                    };

                    try {
                      if (course == null) {
                        final insertResult = await supabase
                            .from('courses')
                            .insert(data)
                            .select();
                        print('✅ Inserted: $insertResult');
                      } else {
                        final updateResult = await supabase
                            .from('courses')
                            .update(data)
                            .eq('id', course['id'] ?? '')
                            .select();
                        print('✅ Updated: $updateResult');
                      }
                      Navigator.pop(context);
                      await _loadCourses();
                    } catch (e) {
                      print('❌ Error saving course: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text(course == null ? 'add'.tr() : 'save'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCourseItem(Map<String, dynamic> course) {
    final teacherId = course['teacher_id'];
    final teacherName = teacherNames[teacherId] ?? '-';
    final start = course['start_time'] ?? '--:--';
    final end = course['end_time'] ?? '--:--';
    final lectureDays = course['lecture_days'] ?? '-';

    return Card(
      child: ListTile(
        title: Text(course['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'teacher'.tr()}: $teacherName'),
            Text('${'start_time'.tr()}: $start'),
            Text('${'end_time'.tr()}: $end'),
            Text('${'lecture_days'.tr()}: $lectureDays'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showCourseDialog(course: course),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('manage_courses'.tr())),
      body: ListView(
        children: courses.map(_buildCourseItem).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourseDialog(),
        tooltip: 'add_course'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
