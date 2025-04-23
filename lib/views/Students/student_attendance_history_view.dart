import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentAttendanceHistoryView extends StatefulWidget {
  const StudentAttendanceHistoryView({super.key});

  @override
  State<StudentAttendanceHistoryView> createState() => _StudentAttendanceHistoryViewState();
}

class _StudentAttendanceHistoryViewState extends State<StudentAttendanceHistoryView> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final userId = supabase.auth.currentUser?.id;

    final response = await supabase
        .from('attendance')
        .select('status, lectures(date, courses(name))')
        .eq('student_id', userId!)
        .order('created_at', ascending: false);

    setState(() {
      _records = List<Map<String, dynamic>>.from(response);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("سجل الحضور")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text("لا يوجد حضور مسجل"))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    final lecture = record['lectures'];
                    final course = lecture['courses'];
                    final date = lecture['date'];
                    final status = record['status'];

                    return ListTile(
                      title: Text(course['name'] ?? 'كورس غير معروف'),
                      subtitle: Text("التاريخ: $date"),
                      trailing: Text(status == 'present' ? "✔ حاضر" : "✖ غائب"),
                    );
                  },
                ),
    );
  }
}
