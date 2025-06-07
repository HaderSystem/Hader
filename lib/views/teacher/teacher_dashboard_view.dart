import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_2/views/teacher/qr_code_view.dart';

import 'CourseDetailsView.dart';

class TeacherDashboardView extends StatefulWidget {
  const TeacherDashboardView({super.key});

  @override
  State<TeacherDashboardView> createState() => _TeacherDashboardViewState();
}

class _TeacherDashboardViewState extends State<TeacherDashboardView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      print("🔒 No logged-in user.");
      return;
    }

    try {
      final data = await _supabase
          .from('courses')
          .select('*')
          .eq('teacher_id', user.id);

      print("✅ Loaded courses: $data");

      setState(() {
        courses = data;
      });
    } catch (e) {
      print("❌ Error loading courses: $e");
    }
  }

  Future<bool> canCreateLecture(String courseId) async {
    final now = DateTime.now();
    final nowTime = TimeOfDay.now();

    final weekDayMap = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final today = weekDayMap[now.weekday]!;

    final course = await _supabase
        .from('courses')
        .select('lecture_days, start_time, end_time')
        .eq('id', courseId)
        .single();

    final days = course['lecture_days'].toString().split(',');

    final startParts = course['start_time'].toString().split(":");
    final endParts = course['end_time'].toString().split(":");

    final startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );

    final endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    final inCorrectDay = days.contains(today);

    final inCorrectTime =
        (nowTime.hour > startTime.hour ||
                (nowTime.hour == startTime.hour &&
                    nowTime.minute >= startTime.minute)) &&
            (nowTime.hour < endTime.hour ||
                (nowTime.hour == endTime.hour &&
                    nowTime.minute <= endTime.minute));

    return inCorrectDay && inCorrectTime;
  }

  void _toggleLanguage(BuildContext context) {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    context.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final email = user?.email ?? 'unknown@example.com';
    final role = user?.userMetadata?['role'] ?? 'admin';
    final name = user?.userMetadata?['name'] ?? 'Admin';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF002D62)),
              ),
              decoration: BoxDecoration(color: colorScheme.primary),
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: Text(tr("settings")),
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(
                    context.locale.languageCode == 'ar'
                        ? tr("english")
                        : tr("arabic"),
                  ),
                  onTap: () => _toggleLanguage(context),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text(tr("change_password")),
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: Text(tr("dark_mode")),
                  onTap: () {
                    ThemeManager.toggleTheme();
                  },
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(tr("logout")),
              onTap: () async {
                await supabase.auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: courses.isEmpty
          ? const Center(
              child: Text(
                "No courses assigned to this teacher.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (_, index) {
                final course = courses[index];
                final String courseId = course['id'].toString();

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CourseDetailsView(courseId: courseId),
                                  ),
                                );
                              },
                              child: const Text("Attendance details"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final canCreate =
                                    await canCreateLecture(courseId);
                                if (!canCreate) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("⏰ Can't create lecture now!"),
                                    ),
                                  );
                                  return;
                                }

                                final lectureInsert = await _supabase
                                    .from('lectures')
                                    .insert({
                                  'course_id': courseId,
                                  'date': DateTime.now()
                                      .toIso8601String()
                                      .substring(0, 10),
                                }).select().single();

                                final lectureId = lectureInsert['id'];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        QRCodeView(lectureId: lectureId),
                                  ),
                                );
                              },
                              child: const Icon(Icons.add),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


