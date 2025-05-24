import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/choose_verification_method_view.dart';
import 'package:flutter_application_2/views/Students/student_course_stats_view.dart';
import 'package:flutter_application_2/views/Students/student_attendance_history_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _courses = [];
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      try {
        final response = await _supabase.storage.from('faces').list();

        final exists = response.any((item) => item.name == '$uid.jpg');

        if (exists) {
          final url = await _supabase.storage
              .from('faces')
              .createSignedUrl('$uid.jpg', 60);
          setState(() {
            _imageUrl = url;
          });
        } else {
          print('❌ Image not found in bucket');
        }
      } catch (e) {
        print('❌ Failed to get image: $e');
      }
    }
  }

  Future<void> _fetchCourses() async {
    final userId = _supabase.auth.currentUser?.id;
    final response = await _supabase
        .from('student_courses')
        .select('courses(id, name)')
        .eq('student_id', userId!);
    setState(() {
      _courses = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final user = _supabase.auth.currentUser;
    final userId = user?.id;
    final email = user?.email ?? 'unknown@student.com';
    final metadata = user?.userMetadata ?? {};
    final name = metadata['name'] ?? 'No Name';
    final universityId = metadata['student_id'] ?? 'Unknown ID';

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("my_courses")),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentAttendanceHistoryView(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: colorScheme.primary,
                  padding: const EdgeInsets.all(16),
                  height: 220,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                        backgroundColor: Colors.white24,
                        child: _imageUrl == null
                            ? const Icon(Icons.person,
                                size: 40, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${tr("profile_id")}: $universityId',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${tr("profile_email")}: $email',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
                      onTap: () {
                        final current = context.locale;
                        final newLocale = current.languageCode == 'ar'
                            ? const Locale('en')
                            : const Locale('ar');
                        context.setLocale(newLocale);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: Text(tr("change_password")),
                      onTap: () =>
                          Navigator.pushNamed(context, '/change-password'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: Text(tr("dark_mode")),
                      onTap: () => ThemeManager.toggleTheme(),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(tr("logout")),
                  onTap: () async {
                    await _supabase.auth.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index]['courses'];
                return ListTile(
                  title: Text(course['name']),
                  subtitle: Text(tr("course_options")),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentCourseStatsView(courseId: course['id']),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChooseVerificationMethodView(userId: userId),
              ),
            );
          }
        },
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
