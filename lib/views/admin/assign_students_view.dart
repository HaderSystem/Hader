import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AssignStudentsView extends StatefulWidget {
  const AssignStudentsView({super.key});

  @override
  State<AssignStudentsView> createState() => _AssignStudentsViewState();
}

class _AssignStudentsViewState extends State<AssignStudentsView> {
  List<dynamic> _students = [];
  List<dynamic> _courses = [];

  String? _selectedStudentId;
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await SupabaseService.admin.auth.admin.listUsers();
final students = users.where((u) => u.email?.contains('student') ?? false).toList();
    final courses = await SupabaseService.client.from('courses').select();

    setState(() {
      _students = students;
      _courses = courses;
    });
  }

  Future<void> _assignStudent() async {
    if (_selectedStudentId == null || _selectedCourseId == null) return;

    await SupabaseService.client.from('student_courses').insert({
      'student_id': _selectedStudentId,
      'course_id': _selectedCourseId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student assigned successfully")),
    );

    setState(() {
      _selectedStudentId = null;
      _selectedCourseId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Students to Courses")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
         DropdownButtonFormField<String>(
  value: _selectedStudentId,
  items: _students.map<DropdownMenuItem<String>>((s) {
    return DropdownMenuItem<String>(
      value: s.id,
      child: Text(s.email ?? ''),
    );
  }).toList(),

              hint: const Text("Select Student"),
              onChanged: (value) {
                setState(() {
                  _selectedStudentId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
  value: _selectedCourseId,
  items: _courses.map<DropdownMenuItem<String>>((c) {
    return DropdownMenuItem<String>(
      value: c['id'],
      child: Text(c['name']),
    );
  }).toList(),

              hint: const Text("Select Course"),
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _assignStudent,
              child: const Text("Assign"),
            )
          ],
        ),
      ),
    );
  }
}
