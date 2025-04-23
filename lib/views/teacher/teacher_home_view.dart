import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'qr_code_view.dart';


class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({super.key});

  @override
  State<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final teacherId = _supabase.auth.currentUser?.id;
    if (teacherId == null) return;

    final response = await _supabase
        .from('courses')
        .select('*')
        .eq('teacher_id', teacherId);

    setState(() {
      _courses = response;
    });
  }
void _createLecture(String courseId) async {
  final inserted = await _supabase
      .from('lectures')
      .insert({
        'course_id': courseId,
        'date': DateTime.now().toIso8601String().substring(0, 10),
      })
      .select()
      .single();

  final lectureId = inserted['id'];

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Lecture Created")),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QRCodeView(lectureId: lectureId),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Dashboard")),
      body: _courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  child: ListTile(
                    title: Text(course['name']),
                    trailing: ElevatedButton(
                      child: const Text("New Lecture"),
                      onPressed: () => _createLecture(course['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
