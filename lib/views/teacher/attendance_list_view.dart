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
    final studentsInCourse = await _supabase
        .from('student_courses')
        .select('student_id, courses!inner(lectures!inner(id))')
        .eq('lectures.id', widget.lectureId);

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
  }

  Widget _buildList(String title, List<dynamic> users) {
    return Expanded(
      child: Column(
        children: [
          Text('$title (${users.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(users[index].toString()),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Overview")),
      body: Row(
        children: [
          _buildList("Present", present),
          _buildList("Absent", absent),
        ],
      ),
    );
  }
}
