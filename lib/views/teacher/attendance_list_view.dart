import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceListView extends StatefulWidget {
  final String lectureId;

  const AttendanceListView({super.key, required this.lectureId});

  @override
  State<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends State<AttendanceListView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> present = [];
  List<dynamic> absent = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    try {
      final lecture = await _supabase
          .from('lectures')
          .select('course_id')
          .eq('id', widget.lectureId)
          .single();

      final courseId = lecture['course_id'];

      final studentsInCourse = await _supabase
          .from('student_courses')
          .select('student_id')
          .eq('course_id', courseId);

      final attended = await _supabase
          .from('attendance')
          .select('student_id')
          .eq('lecture_id', widget.lectureId);

      final presentIds = attended.map((a) => a['student_id']).toSet();
      final allStudents = studentsInCourse.map((s) => s['student_id']).toSet();

      setState(() {
        present = presentIds.toList();
        absent = allStudents.difference(presentIds).toList();
      });
    } catch (e) {
      print('❌ Error fetching attendance: $e');
    }
  }

  Widget _buildList(String title, List<dynamic> users, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${users.length})',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        'No students',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, index) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.person, color: color),
                          title: Text(
                            users[index].toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Overview"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Row(
          children: [
            _buildList("Present", present, Colors.green),
            _buildList("Absent", absent, Colors.red),
          ],
        ),
      ),
    );
  }
}
