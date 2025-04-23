import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/student_course_stats_view.dart';
import 'package:flutter_application_2/views/Students/face_verification_view.dart';
import 'package:flutter_application_2/views/Students/student_attendance_history_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final userId = _supabase.auth.currentUser?.id;

    final response = await _supabase
        .from('student_courses')
        .select('courses(id, name)')
        .eq('student_id', userId!);

    setState(() {
      _courses = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("my courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              final userId =
                  Supabase.instance.client.auth.currentUser!.id;
              Navigator.push(
                context,
                MaterialPageRoute(
                      builder: (_) => const StudentAttendanceHistoryView(),
                ),
              );
            },
          )
        ],
      ),
      body: _courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index]['courses'];
                return ListTile(
                  title: Text(course['name']),
                  subtitle: const Text("عرض إحصائيات + تسجيل حضور"),
                  onTap: () {
                    final userId =
                        Supabase.instance.client.auth.currentUser!.id;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentCourseStatsView(courseId: course['id']),
                      ),
                    );
                  },
                  onLongPress: () {
                    final userId =
                        Supabase.instance.client.auth.currentUser!.id;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FaceVerificationView(userId: userId),
                      ),
                    );
                  },
                  trailing: const Icon(Icons.camera_alt),
                );
              },
            ),
    );
  }
}
