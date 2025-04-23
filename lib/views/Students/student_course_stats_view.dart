import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentCourseStatsView extends StatefulWidget {
  final String courseId;
  const StudentCourseStatsView({super.key, required this.courseId});

  @override
  State<StudentCourseStatsView> createState() => _StudentCourseStatsViewState();
}

class _StudentCourseStatsViewState extends State<StudentCourseStatsView> {
  final _supabase = Supabase.instance.client;

  int totalLectures = 0;
  int presentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = _supabase.auth.currentUser!.id;

    final lectures = await _supabase
        .from('lectures')
        .select('id')
        .eq('course_id', widget.courseId);

    final lectureIds = lectures.map((l) => l['id']).toList();

    final attendance = await _supabase
        .from('attendance')
        .select()
        .eq('student_id', userId)
        .in_('lecture_id', lectureIds);

    final present = attendance.where((a) => a['status'] == 'present').length;

    setState(() {
      totalLectures = lectureIds.length;
      presentCount = present;
    });
  }

  @override
  Widget build(BuildContext context) {
    final absentCount = totalLectures - presentCount;
    final showWarning = absentCount >= 3;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Stats")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Lectures: $totalLectures",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Present: $presentCount",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Absent: $absentCount",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            if (showWarning)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "تنبيه: تجاوزت الحد المسموح من الغيابات!",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
