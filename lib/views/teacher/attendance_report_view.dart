import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/supabase_service.dart';

class AttendanceReportView extends StatefulWidget {
  const AttendanceReportView({super.key});

  @override
  State<AttendanceReportView> createState() => _AttendanceReportViewState();
}

class _AttendanceReportViewState extends State<AttendanceReportView> {
  List<dynamic> _courses = [];
  List<Map<String, dynamic>> _report = [];
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final courses = await SupabaseService.client.from('courses').select();
    setState(() {
      _courses = courses;
    });
  }

  Future<void> _generateReport(String courseId) async {
    final lectures = await SupabaseService.client
        .from('lectures')
        .select('id')
        .eq('course_id', courseId);

    final lectureIds = lectures.map((l) => l['id']).toList();

    final studentLinks = await SupabaseService.client
        .from('student_courses')
        .select('student_id')
        .eq('course_id', courseId);

    final List<Map<String, dynamic>> report = [];

    for (final link in studentLinks) {
      final studentId = link['student_id'];

      final attended = await SupabaseService.client
          .from('attendance')
          .select()
          .in_('lecture_id', lectureIds)
          .eq('student_id', studentId);

      final attendedCount =
          attended.where((a) => a['status'] == 'present').length;

      report.add({
        'student_id': studentId,
        'total': lectureIds.length,
        'present': attendedCount,
        'absent': lectureIds.length - attendedCount,
      });
    }

    setState(() {
      _report = report;
    });
  }

  Future<void> _exportCSV() async {
    final headers = ['Student ID', 'Total Lectures', 'Present', 'Absent'];
    final rows = _report.map((entry) => [
          entry['student_id'],
          entry['total'],
          entry['present'],
          entry['absent'],
        ]).toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
      return;
    }

    final directory = await getExternalStorageDirectory();
    final path = "${directory!.path}/attendance_report.csv";

    final file = File(path);
    await file.writeAsString(csvData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report saved to $path")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Report"),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Course',
                ),
                value: _selectedCourseId,
                items: _courses.map<DropdownMenuItem<String>>((c) {
                  return DropdownMenuItem<String>(
                    value: c['id'],
                    child: Text(c['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCourseId = val;
                    _report.clear();
                  });
                  if (val != null) _generateReport(val);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _report.isEmpty ? null : _exportCSV,
              child: const Text("Export as CSV"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _report.isEmpty
                  ? const Center(
                      child: Text(
                        "No data available. Please select a course.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _report.length,
                      itemBuilder: (_, index) {
                        final entry = _report[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text("Student: ${entry['student_id']}"),
                            subtitle: Text(
                              "Present: ${entry['present']} | Absent: ${entry['absent']} / ${entry['total']}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
