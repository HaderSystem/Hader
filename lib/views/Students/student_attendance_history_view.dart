import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("سجل الحضور")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text("لا يوجد حضور مسجل"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    final lecture = record['lectures'];
                    final course = lecture['courses'];
                    final rawDate = lecture['date'];
                    final status = record['status'];

                    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(rawDate));
                    final isPresent = status == 'present';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          course['name'] ?? 'كورس غير معروف',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("📅 التاريخ: $formattedDate"),
                        trailing: Text(
                          isPresent ? "✔ حاضر" : "✖ غائب",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
