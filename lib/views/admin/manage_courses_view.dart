import 'package:flutter/material.dart';
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
