//This page shows the student's course status and absences
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart'; 

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
  String courseName = '';
  String startTime = '';
  String endTime = '';
  String teacherName = '';
  List<DateTime> absentDates = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = _supabase.auth.currentUser!.id;

    final course = await _supabase
        .from('courses')
        .select('name, start_time, end_time, teacher_id')
        .eq('id', widget.courseId)
        .maybeSingle();

    if (course != null && mounted) {
      setState(() {
        courseName = course['name'] ?? '';
        startTime = course['start_time'] ?? '';
        endTime = course['end_time'] ?? '';
      });

      if (course['teacher_id'] != null) {
        final teacher = await _supabase
            .from('teachers')
            .select('name')
            .eq('id', course['teacher_id'])
            .maybeSingle();

        if (teacher != null && mounted) {
          setState(() {
            teacherName = teacher['name'] ?? '';
          });
        }
      }
    }

    final lectures = await _supabase
        .from('lectures')
        .select('id, date')
        .eq('course_id', widget.courseId);

    final lectureIds = lectures.map((l) => l['id']).toList();

    final attendance = await _supabase
        .from('attendance')
        .select()
        .eq('student_id', userId)
        .in_('lecture_id', lectureIds);

    final present = attendance.where((a) => a['status'] == 'present').length;

    final absentLectures = <DateTime>[];
    for (var lecture in lectures) {
      final lectureId = lecture['id'];
      final attended = attendance.any((a) =>
          a['lecture_id'] == lectureId && a['status'] == 'present');
      if (!attended && lecture['date'] != null) {
        absentLectures.add(DateTime.parse(lecture['date']));
      }
    }

    if (!mounted) return;
    setState(() {
      totalLectures = lectureIds.length;
      presentCount = present;
      absentDates = absentLectures;
    });
  }

  @override
  Widget build(BuildContext context) {
    final absentCount = totalLectures - presentCount;
    final showWarning = absentCount >= 7;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("attendance_statistics")),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (courseName.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tr("course_name")}: $courseName',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${tr("lecture_time")}: $startTime - $endTime',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    if (teacherName.isNotEmpty)
                      Text('${tr("teacher_name")}: $teacherName',
                          style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                  ],
                ),
              StatCard(
                label: tr("total_lectures"),
                value: totalLectures.toString(),
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              StatCard(
                label: tr("present"),
                value: presentCount.toString(),
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              StatCard(
                label: tr("absent"),
                value: absentCount.toString(),
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              if (absentDates.isNotEmpty)
                ExpansionTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.red),
                  title: Text(tr("absent_dates"),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: absentDates.map((date) {
                    return ListTile(
                      leading: const Icon(Icons.close, color: Colors.red),
                      title: Text(DateFormat('yyyy-MM-dd – EEEE', context.locale.toString())
                          .format(date)),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              if (showWarning)
                Card(
                  color: Colors.red.shade100,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      tr("absence_warning"),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.bar_chart, color: color),
        ),
        title: Text(label, style: theme.textTheme.bodyLarge),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
