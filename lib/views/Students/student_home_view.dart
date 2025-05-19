import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/choose_verification_method_view.dart';
import 'package:flutter_application_2/views/Students/student_course_stats_view.dart';
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
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentAttendanceHistoryView(),
                ),
              );
            },
          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentCourseStatsView(courseId: course['id']),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChooseVerificationMethodView(userId: userId),
              ),
            );
          }
        },
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
