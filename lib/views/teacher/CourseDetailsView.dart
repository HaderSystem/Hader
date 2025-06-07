import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseDetailsView extends StatefulWidget {
  final String courseId;

  const CourseDetailsView({super.key, required this.courseId});

  @override
  State<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<CourseDetailsView> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> lectures = [];
  Map<String, dynamic>? selectedLecture;

  List<Map<String, dynamic>> students = [];
  Set<String> presentStudentIds = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLectures();
    _loadStudents();
  }

  Future<void> _loadLectures() async {
    try {
      final res = await _supabase
          .from('lectures')
          .select('id, date')
          .eq('course_id', widget.courseId)
          .order('date', ascending: true);

      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      final todayLecture = res.firstWhere(
        (lecture) => lecture['date'].toString().startsWith(todayDate),
        orElse: () => null,
      );

      setState(() {
        lectures = List<Map<String, dynamic>>.from(res);
        if (todayLecture != null) {
          selectedLecture = todayLecture;
          _loadAttendance();
        }
      });
    } catch (e) {
      print("❌ Error loading lectures: $e");
    }
  }

  Future<void> _loadStudents() async {
    try {
      final studentCourses = await _supabase
          .from('student_courses')
          .select('student_id')
          .eq('course_id', widget.courseId);

      final studentIds = studentCourses.map((e) => e['student_id']).toList();

      if (studentIds.isEmpty) {
        setState(() {
          students = [];
        });
        return;
      }

      final studentsRes = await _supabase
          .from('students')
          .select('id, name')
          .in_('id', studentIds);

      setState(() {
        students = List<Map<String, dynamic>>.from(studentsRes);
      });
    } catch (e) {
      print("❌ Error loading students: $e");
    }
  }

  Future<void> _loadAttendance() async {
    if (selectedLecture == null) return;

    final lectureId = selectedLecture!['id'];

    try {
      final attendanceRes = await _supabase
          .from('attendance')
          .select('student_id')
          .eq('lecture_id', lectureId);

      setState(() {
        presentStudentIds = attendanceRes
            .map<String>((row) => row['student_id'].toString())
            .toSet();
      });
    } catch (e) {
      print("❌ Error loading attendance: $e");
    }
  }

  void _updateAttendance(String studentId, bool isPresent) async {
    final lectureId = selectedLecture!['id'];

    if (isPresent) {
      await _supabase.from('attendance').upsert({
        'lecture_id': lectureId,
        'student_id': studentId,
        'status': 'present',
      }, onConflict: 'lecture_id,student_id');
    } else {
      await _supabase
          .from('attendance')
          .delete()
          .match({'lecture_id': lectureId, 'student_id': studentId});
    }

    setState(() {
      if (isPresent) {
        presentStudentIds.add(studentId);
      } else {
        presentStudentIds.remove(studentId);
      }
    });
  }

  Future<void> _createLectureNow() async {
    final now = DateTime.now();
    final todayDate = now.toIso8601String().split('T')[0];
    final day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][now.weekday % 7];

    final course = await _supabase
        .from('courses')
        .select()
        .eq('id', widget.courseId)
        .single();

    final rawDays = course['days'];
    final allowedDays = rawDays is List ? List<String>.from(rawDays) : [];

    final startTime = TimeOfDay(
      hour: int.parse(course['start_time'].split(':')[0]),
      minute: int.parse(course['start_time'].split(':')[1]),
    );
    final endTime = TimeOfDay(
      hour: int.parse(course['end_time'].split(':')[0]),
      minute: int.parse(course['end_time'].split(':')[1]),
    );

    final currentTime = TimeOfDay.fromDateTime(now);

    bool isTimeAllowed = allowedDays.contains(day) &&
        (currentTime.hour > startTime.hour ||
            (currentTime.hour == startTime.hour && currentTime.minute >= startTime.minute)) &&
        (currentTime.hour < endTime.hour ||
            (currentTime.hour == endTime.hour && currentTime.minute <= endTime.minute));

    if (!isTimeAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⛔ الوقت غير مسموح بإنشاء محاضرة الآن")),
      );
      return;
    }

    final existing = await _supabase
        .from('lectures')
        .select()
        .eq('course_id', widget.courseId)
        .eq('date', todayDate);

    if (existing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ تم إنشاء محاضرة بالفعل اليوم لهذا الكورس")),
      );
      return;
    }

    await _supabase.from('lectures').insert({
      'course_id': widget.courseId,
      'date': todayDate,
    });

    await _loadLectures();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم إنشاء المحاضرة")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Details"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createLectureNow,
            tooltip: "Create lecture now",
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  hint: const Text("Select Lecture Date"),
                  value: selectedLecture,
                  items: lectures.map((lecture) {
                    final date = lecture['date'].toString().substring(0, 10);
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: lecture,
                      child: Text(date),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    setState(() => selectedLecture = value);
                    await _loadAttendance();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: students.isEmpty
                  ? const Center(
                      child: Text(
                        "No students found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final studentId = student['id'];
                        final studentName = student['name'];
                        final isPresent = presentStudentIds.contains(studentId);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            title: Text(studentName),
                            value: isPresent,
                            onChanged: selectedLecture != null
                                ? (value) {
                                    _updateAttendance(studentId, value!);
                                  }
                                : null,
                            controlAffinity: ListTileControlAffinity.leading,
                            subtitle: !isPresent
                                ? const Text("Absent", style: TextStyle(color: Colors.red))
                                : const Text("Present", style: TextStyle(color: Colors.green)),
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
