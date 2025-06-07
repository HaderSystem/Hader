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
      appBar: AppBar(
        title: const Text("إحصائيات الحضور"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            StatCard(
              label: "📚 عدد المحاضرات",
              value: totalLectures.toString(),
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            StatCard(
              label: "✅ الحضور",
              value: presentCount.toString(),
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            StatCard(
              label: "❌ الغياب",
              value: absentCount.toString(),
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            if (showWarning)
              Card(
                color: Colors.red.shade100,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "⚠️ تنبيه: تجاوزت الحد المسموح من الغيابات!",
                    style: TextStyle(
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
