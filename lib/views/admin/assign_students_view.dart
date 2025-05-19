import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AssignStudentsView extends StatefulWidget {
  const AssignStudentsView({super.key});

  @override
  State<AssignStudentsView> createState() => _AssignStudentsViewState();
}

class _AssignStudentsViewState extends State<AssignStudentsView> {
  List<dynamic> _courses = [];
  List<dynamic> _teachers = [];
  List<dynamic> _students = [];

  String? _selectedCourseId;
  String? _selectedTeacherId;
  List<String> _selectedStudentIds = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final users = await SupabaseService.admin.auth.admin.listUsers();
    final teachers = users.where((u) => u.userMetadata?['role'] == 'teacher').toList();
    final courses = await SupabaseService.client.from('courses').select();

    setState(() {
      _teachers = teachers;
      _courses = courses;
    });
  }

  Future<void> _loadAvailableStudents(String courseId) async {
    // 1. الطلاب المخصصين مسبقًا لهاد الكورس
    final assigned = await SupabaseService.client
        .from('student_courses')
        .select('student_id')
        .eq('course_id', courseId);

    final assignedIds = assigned.map<String>((row) => row['student_id'] as String).toList();

    // 2. كل الطلاب
    final users = await SupabaseService.admin.auth.admin.listUsers();
    final allStudents = users.where((u) => u.userMetadata?['role'] == 'student').toList();

    // 3. فلترة الطلاب غير المعينين
    final available = allStudents.where((u) => !assignedIds.contains(u.id)).toList();

    setState(() {
      _students = available;
      _selectedStudentIds.clear();
    });
  }

  Future<void> _assignStudentsAndTeacher() async {
    if (_selectedCourseId == null || _selectedTeacherId == null || _selectedStudentIds.isEmpty) return;

    setState(() => _loading = true);

    try {
      // تحديث المعلم
      await SupabaseService.client
          .from('courses')
          .update({'teacher_id': _selectedTeacherId})
          .eq('id', _selectedCourseId);

      // ربط كل طالب بالكورس
      for (final studentId in _selectedStudentIds) {
        await SupabaseService.client.from('student_courses').insert({
          'student_id': studentId,
          'course_id': _selectedCourseId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment completed successfully")),
      );

      setState(() {
        _selectedCourseId = null;
        _selectedTeacherId = null;
        _students = [];
        _selectedStudentIds = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Students & Teacher")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اختيار الكورس
                    DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(labelText: 'Select Course'),
                      items: _courses.map<DropdownMenuItem<String>>((c) {
                        return DropdownMenuItem<String>(
                          value: c['id'],
                          child: Text(c['name']),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCourseId = val);
                        if (val != null) _loadAvailableStudents(val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // اختيار المعلم
                    DropdownButtonFormField<String>(
                      value: _selectedTeacherId,
                      decoration: const InputDecoration(labelText: 'Select Teacher'),
                      items: _teachers.map<DropdownMenuItem<String>>((t) {
                        final fullName = t.userMetadata?['full_name'] ??
                            t.userMetadata?['name'] ??
                            t.email ??
                            'No Name';
                        return DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(fullName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTeacherId = val),
                    ),
                    const SizedBox(height: 16),

                    // اختيار الطلاب
                    const Text('Select Students:'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _students.map((student) {
                        final id = student.id;
                        final selected = _selectedStudentIds.contains(id);
                        final universityId = student.userMetadata?['university_id'] ??
                            student.userMetadata?['student_id'] ??
                            student.email ??
                            'No ID';

                        return FilterChip(
                          label: Text(universityId),
                          selected: selected,
                          onSelected: (bool value) {
                            setState(() {
                              if (value) {
                                _selectedStudentIds.add(id);
                              } else {
                                _selectedStudentIds.remove(id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _assignStudentsAndTeacher,
                        child: const Text("Assign"),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
