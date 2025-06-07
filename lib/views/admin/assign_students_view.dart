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

  List<dynamic> _availableStudents = [];
  List<dynamic> _assignedStudents = [];

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
    final teachers =
        users.where((u) => u.userMetadata?['role'] == 'teacher').toList();
    final courses = await SupabaseService.client.from('courses').select();

    setState(() {
      _teachers = teachers;
      _courses = courses;
    });
  }

  Future<void> _loadAvailableStudents(String courseId) async {
    final assigned = await SupabaseService.client
        .from('student_courses')
        .select('student_id')
        .eq('course_id', courseId);

    final assignedIds =
        assigned.map<String>((row) => row['student_id'] as String).toList();

    final users = await SupabaseService.admin.auth.admin.listUsers();
    final allStudents =
        users.where((u) => u.userMetadata?['role'] == 'student').toList();

    final available =
        allStudents.where((u) => !assignedIds.contains(u.id)).toList();
    final assignedStudents =
        allStudents.where((u) => assignedIds.contains(u.id)).toList();

    setState(() {
      _availableStudents = available;
      _assignedStudents = assignedStudents;
      _selectedStudentIds = assignedIds;
    });
  }

  Future<void> _assignStudentsAndTeacher() async {
    if (_selectedCourseId == null ||
        _selectedTeacherId == null ||
        _selectedStudentIds.isEmpty) return;

    setState(() => _loading = true);

    try {
      await SupabaseService.client
          .from('courses')
          .update({'teacher_id': _selectedTeacherId})
          .eq('id', _selectedCourseId);

      await SupabaseService.client
          .from('student_courses')
          .delete()
          .eq('course_id', _selectedCourseId);

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
        _availableStudents = [];
        _assignedStudents = [];
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Assign Students & Teacher")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth > 600
                            ? 700
                            : double.infinity),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _selectedCourseId,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Course',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _courses
                                        .map<DropdownMenuItem<String>>((c) =>
                                            DropdownMenuItem<String>(
                                                value: c['id'],
                                                child: Text(c['name'])))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() => _selectedCourseId = val);
                                      if (val != null) _loadAvailableStudents(val);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedTeacherId,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Teacher',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _teachers
                                        .map<DropdownMenuItem<String>>((t) {
                                      final fullName =
                                          t.userMetadata?['full_name'] ??
                                              t.userMetadata?['name'] ??
                                              t.email ??
                                              'No Name';
                                      return DropdownMenuItem<String>(
                                        value: t.id,
                                        child: Text(fullName),
                                      );
                                    }).toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedTeacherId = val),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '✅ Assigned Students:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _assignedStudents.map((student) {
                                      final id = student.id;
                                      final universityId =
                                          student.userMetadata?['student_id']
                                                  ?.toString() ??
                                              student.email ??
                                              'No ID';

                                      return FilterChip(
                                        label: Text(universityId),
                                        selected: true,
                                        onSelected: (val) {
                                          setState(() {
                                            _assignedStudents
                                                .removeWhere((s) => s.id == id);
                                            _availableStudents.add(student);
                                            _selectedStudentIds.remove(id);
                                          });
                                        },
                                        selectedColor: theme.colorScheme.primary,
                                        backgroundColor: Colors.grey.shade200,
                                        labelStyle: const TextStyle(
                                            color: Colors.white),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    '❌ Unassigned Students:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _availableStudents.map((student) {
                                      final id = student.id;
                                      final universityId =
                                          student.userMetadata?['student_id']
                                                  ?.toString() ??
                                              student.email ??
                                              'No ID';

                                      return FilterChip(
                                        label: Text(universityId),
                                        selected: false,
                                        onSelected: (val) {
                                          setState(() {
                                            _availableStudents
                                                .removeWhere((s) => s.id == id);
                                            _assignedStudents.add(student);
                                            _selectedStudentIds.add(id);
                                          });
                                        },
                                        selectedColor: theme.colorScheme.primary,
                                        backgroundColor: Colors.grey.shade200,
                                        labelStyle: const TextStyle(
                                            color: Colors.black87),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text("Assign",
                                  style: TextStyle(fontSize: 16)),
                              onPressed: _assignStudentsAndTeacher,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


/* import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class AssignStudentsView extends StatefulWidget {
  const AssignStudentsView({super.key});

  @override
  State<AssignStudentsView> createState() => _AssignStudentsViewState();
}

class _AssignStudentsViewState extends State<AssignStudentsView> {
  List<dynamic> _courses = [];
  List<dynamic> _teachers = [];

  List<dynamic> _availableStudents = [];
  List<dynamic> _assignedStudents = [];

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
    final teachers =
        users.where((u) => u.userMetadata?['role'] == 'teacher').toList();
    final courses = await SupabaseService.client.from('courses').select();


    setState(() {
      _teachers = teachers;
      _courses = courses;
      
    });
    
  }

  Future<void> _loadAvailableStudents(String courseId) async {
    final assigned = await SupabaseService.client
        .from('student_courses')
        .select('student_id')
        .eq('course_id', courseId);

    final assignedIds =
        assigned.map<String>((row) => row['student_id'] as String).toList();

    final users = await SupabaseService.admin.auth.admin.listUsers();
    final allStudents =
        users.where((u) => u.userMetadata?['role'] == 'student').toList();

    final available =
        allStudents.where((u) => !assignedIds.contains(u.id)).toList();
    final assignedStudents =
        allStudents.where((u) => assignedIds.contains(u.id)).toList();


print('📡 assignedIds: $assignedIds');
print('📦 allStudents: ${allStudents.map((e) => e.id)}');


    setState(() {
      _availableStudents = available;
      _assignedStudents = assignedStudents;
      _selectedStudentIds = assignedIds;
    });
  }

  Future<void> _assignStudentsAndTeacher() async {
    if (_selectedCourseId == null ||
        _selectedTeacherId == null ||
        _selectedStudentIds.isEmpty) return;

    setState(() => _loading = true);

    try {
      await SupabaseService.client
          .from('courses')
          .update({'teacher_id': _selectedTeacherId})
          .eq('id', _selectedCourseId);

      await SupabaseService.client
          .from('student_courses')
          .delete()
          .eq('course_id', _selectedCourseId);

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
        _availableStudents = [];
        _assignedStudents = [];
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Assign Students & Teacher")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedCourseId,
                              decoration: const InputDecoration(
                                labelText: 'Select Course',
                                border: OutlineInputBorder(),
                              ),
                              items: _courses
                                  .map<DropdownMenuItem<String>>((c) =>
                                      DropdownMenuItem<String>(
                                          value: c['id'],
                                          child: Text(c['name'])))
                                  .toList(),
                              onChanged: (val) {
                                setState(() => _selectedCourseId = val);
                                if (val != null) _loadAvailableStudents(val);
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedTeacherId,
                              decoration: const InputDecoration(
                                labelText: 'Select Teacher',
                                border: OutlineInputBorder(),
                              ),
                              items: _teachers
                                  .map<DropdownMenuItem<String>>((t) {
                                final fullName = t.userMetadata?['full_name'] ??
                                    t.userMetadata?['name'] ??
                                    t.email ??
                                    'No Name';
                                return DropdownMenuItem<String>(
                                  value: t.id,
                                  child: Text(fullName),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedTeacherId = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '✅ Assigned Students:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _assignedStudents.map((student) {
                                final id = student.id;
                                final universityId = student
                                        .userMetadata?['student_id']
                                        ?.toString() ??
                                    student.email ??
                                    'No ID';

                                return FilterChip(
                                  label: Text(universityId),
                                  selected: true,
                                  onSelected: (val) {
                                    setState(() {
                                      _assignedStudents
                                          .removeWhere((s) => s.id == id);
                                      _availableStudents.add(student);
                                      _selectedStudentIds.remove(id);
                                    });
                                  },
                                  selectedColor: theme.colorScheme.primary,
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '❌ Unassigned Students:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableStudents.map((student) {
                                final id = student.id;
                                final universityId = student
                                        .userMetadata?['student_id']
                                        ?.toString() ??
                                    student.email ??
                                    'No ID';

                                return FilterChip(
                                  label: Text(universityId),
                                  selected: false,
                                  onSelected: (val) {
                                    setState(() {
                                      _availableStudents
                                          .removeWhere((s) => s.id == id);
                                      _assignedStudents.add(student);
                                      _selectedStudentIds.add(id);
                                    });
                                  },
                                  selectedColor: theme.colorScheme.primary,
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle:
                                      const TextStyle(color: Colors.black87),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text("Assign",
                            style: TextStyle(fontSize: 16)),
                        onPressed: _assignStudentsAndTeacher,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
 */