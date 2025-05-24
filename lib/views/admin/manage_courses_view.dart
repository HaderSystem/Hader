// كود حنين

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ManageCoursesView extends StatefulWidget {
  const ManageCoursesView({super.key});

  @override
  State<ManageCoursesView> createState() => _ManageCoursesViewState();
}

class _ManageCoursesViewState extends State<ManageCoursesView> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();

  String? _selectedTeacher;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Set<String> _selectedDays = {};

  List<dynamic> _courses = [];
  List<dynamic> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courses = await supabase.from('courses').select();
   final teachers = await supabase
    .from('teachers')
    .select('id, name, email');


     if (kDebugMode) {
       print('Teachers fetched: $teachers');
     }


    setState(() {
      _courses = courses;
      _teachers = teachers;
    });
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Course"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Course Name"),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedTeacher,
                  hint: const Text("Select Teacher"),
                  items: _teachers.map<DropdownMenuItem<String>>((t) {
                    return DropdownMenuItem<String>(
                      value: t['id'],
                      child: Text(t['full_name'] ?? t['email'] ?? "---"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTeacher = val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _startDate = picked);
                        },
                        child: Text(_startDate == null
                            ? "Select Start Date"
                            : "Start: \${_startDate!.toLocal().toString().split(' ')[0]}"),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                        child: Text(_endDate == null
                            ? "Select End Date"
                            : "End: \${_endDate!.toLocal().toString().split(' ')[0]}"),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) setState(() => _startTime = picked);
                        },
                        child: Text(_startTime == null
                            ? "Start Time"
                            : "Start: \${_startTime!.format(context)}"),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) setState(() => _endTime = picked);
                        },
                        child: Text(_endTime == null
                            ? "End Time"
                            : "End: \${_endTime!.format(context)}"),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  children: ["sun", "mon", "tue", "wed", "thu"]
                      .map((day) => FilterChip(
                            label: Text(day.toUpperCase()),
                            selected: _selectedDays.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                selected ? _selectedDays.add(day) : _selectedDays.remove(day);
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addCourse,
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCourse() async {
    final name = _nameController.text.trim();
    if (name.isEmpty ||
        _selectedTeacher == null ||
        _startDate == null ||
        _endDate == null ||
        _startTime == null ||
        _endTime == null ||
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Start date must be before end date")),
      );
      return;
    }

    String formatTime(TimeOfDay time) {
      return "\${time.hour.toString().padLeft(2, '0')}:\${time.minute.toString().padLeft(2, '0')}";
    }

    await supabase.from('courses').insert({
      'name': name,
      'teacher_id': _selectedTeacher,
      'start_date': _startDate!.toIso8601String(),
      'end_date': _endDate!.toIso8601String(),
      'start_time': formatTime(_startTime!),
      'end_time': formatTime(_endTime!),
      'lecture_days': _selectedDays.join(','),
    });

    Navigator.pop(context);
    _nameController.clear();
    _selectedTeacher = null;
    _startDate = null;
    _endDate = null;
    _startTime = null;
    _endTime = null;
    _selectedDays.clear();
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Course added successfully")),
    );
  }

  Future<void> _generateLecturesForCourse(Map<String, dynamic> course) async {
  final courseId = course['id'];

  if (course['start_date'] == null || course['end_date'] == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Missing start or end date for this course")),
    );
    return;
  }

  final startDate = DateTime.parse(course['start_date']);
  final endDate = DateTime.parse(course['end_date']);
  final startTime = course['start_time'];
  final endTime = course['end_time'];
  final lectureDays = (course['lecture_days'] ?? '').split(',');
  
    Map<String, int> dayToIndex = {
      'sun': DateTime.sunday,
      'mon': DateTime.monday,
      'tue': DateTime.tuesday,
      'wed': DateTime.wednesday,
      'thu': DateTime.thursday,
    };

    final lectureDates = <DateTime>[];

    for (DateTime day = startDate;
        !day.isAfter(endDate);
        day = day.add(const Duration(days: 1))) {
      final shortDay = dayToIndex.entries
          .firstWhere((e) => e.value == day.weekday, orElse: () => MapEntry('', 0))
          .key;

      if (lectureDays.contains(shortDay)) {
        lectureDates.add(day);
      }
    }

    for (final date in lectureDates) {
      await supabase.from('lectures').insert({
        'course_id': courseId,
        'date': date.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text("Lectures generated for ${course['name']}")),

    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Manage Courses"),
      backgroundColor: const Color(0xFF002D62),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        if (_teachers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No teachers available")),
          );
        } else {
          _showAddCourseDialog();
        }
      },
      backgroundColor: const Color(0xFF002D62),
      child: const Icon(Icons.add),
    ),
    body: Column(
      children: [
        Text("Teachers count: ${_teachers.length}"), // 👈 أضفناه هون
        Expanded(
          child: _courses.isEmpty
              ? const Center(child: Text("No courses yet."))
              : ListView.builder(
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    final days = course['lecture_days'] ?? '';
                    final start = course['start_time'] ?? '??';
                    final end = course['end_time'] ?? '??';
                    final startDate =
                        course['start_date']?.toString().split('T').first ?? '';
                    final endDate =
                        course['end_date']?.toString().split('T').first ?? '';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(course['name'] ?? 'No name'),
                            subtitle: Text(
                              "From $startDate to $endDate\nTime: $start - $end\nDays: $days",
                            ),
                            trailing: const Icon(Icons.info_outline),
                            onTap: () {},
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, bottom: 10),
                            child: TextButton.icon(
                              onPressed: () async {
                                await _generateLecturesForCourse(course);
                              },
                              icon: const Icon(Icons.auto_mode),
                              label: const Text("Generate Lectures"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
}


// كود ععائشة

/* import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'assign_students_view.dart';
import 'package:easy_localization/easy_localization.dart';

class ManageCoursesView extends StatefulWidget {
  const ManageCoursesView({super.key});

  @override
  State<ManageCoursesView> createState() => _ManageCoursesViewState();
}

class _ManageCoursesViewState extends State<ManageCoursesView> {
  final supabase = Supabase.instance.client;
  List<dynamic> _courses = [];
  List<dynamic> _teachers = [];
  List<dynamic> _students = [];
  List<dynamic> _studentCourses = [];
  final _nameController = TextEditingController();
  String? _selectedTeacher;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courses = await supabase.from('courses').select();
    final teachers = await supabase.from('teachers').select();
    final students = await supabase.from('students').select();
    final studentCourses = await supabase.from('student_courses').select();

    setState(() {
      _courses = courses;
      _teachers = teachers;
      _students = students;
      _studentCourses = studentCourses;
    });
  }

  Future<void> _addCourse() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedTeacher == null) return;

    await supabase.from('courses').insert({
      'name': name,
      'teacher_id': _selectedTeacher,
    });

    Navigator.pop(context);
    _nameController.clear();
    _selectedTeacher = null;
    await _loadData();
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(tr("add_course")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: tr("course_name")),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTeacher,
                hint: Text(tr("select_teacher")),
                items: _teachers.map<DropdownMenuItem<String>>((t) {
                  return DropdownMenuItem<String>(
                    value: t['id'],
                    child: Text(t['full_name'] ?? t['email'] ?? tr("not_assigned")),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedTeacher = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(tr("cancel"))),
            ElevatedButton(onPressed: _addCourse, child: Text(tr("save"))),
          ],
        );
      },
    );
  }

  List<String> _getStudentUniversityIds(String courseId) {
    final studentIds = _studentCourses
        .where((row) => row['course_id'] == courseId)
        .map<String>((row) => row['student_id'] as String)
        .toList();

    final studentUniversityIds = <String>[];

    for (var sid in studentIds) {
      final matches = _students.where((s) => s['id'] == sid);
      if (matches.isNotEmpty) {
        final student = matches.first;
        final universityId = student['student_id']?.toString().trim();
        final email = student['email']?.toString().trim();

        if (universityId != null && universityId.isNotEmpty) {
          studentUniversityIds.add(universityId);
        } else if (email != null && email.isNotEmpty) {
          studentUniversityIds.add(email);
        } else {
          studentUniversityIds.add('---');
        }
      } else {
        studentUniversityIds.add('---');
      }
    }

    return studentUniversityIds;
  }

  void _toggleLanguage() {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  void _showCourseDetailsDialog(Map<String, dynamic> course) {
    final teacher = _teachers.firstWhere(
      (t) => t['id'] == course['teacher_id'],
      orElse: () => null,
    );

    final teacherName = teacher?['full_name'] ?? teacher?['email'] ?? tr("not_assigned");
    final studentUniversityIds = _getStudentUniversityIds(course['id']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr("course_details")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${tr("course_name")}: ${course['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("${tr("teacher")}: $teacherName"),
            const SizedBox(height: 10),
            Text(tr("students"), style: const TextStyle(fontWeight: FontWeight.bold)),
            if (studentUniversityIds.isEmpty)
              Text(tr("no_students"))
            else
              ...studentUniversityIds.map((id) => Text("- $id")),
            const SizedBox(height: 12),
            const Divider(),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignStudentsView(),
                  ),
                ).then((_) {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr("navigated_to_assign"))),
                  );
                });
              },
              child: Text(tr("manage_students")),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr("close")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("manage_courses")),
        backgroundColor: const Color(0xFF002D62),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: tr("change_language"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
  if (_teachers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr("no_teachers_available"))),
    );
  } else {
    _showAddCourseDialog();
  }
},
        backgroundColor: const Color(0xFF002D62),
        child: const Icon(Icons.add),
      ),
      body: _courses.isEmpty
          ? Center(child: Text(tr("no_courses")))
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                final courseName = course['name'];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text("${tr("course_name")}: $courseName"),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showCourseDetailsDialog(course),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
 */