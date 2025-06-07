import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/student_course_stats_view.dart';
import 'package:flutter_application_2/views/Students/student_attendance_history_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';
import 'face_recognition_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _courses = [];
  String? _imageUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
    _fetchCourses();
  }

  Future<void> _loadImageUrl() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid != null) {
      try {
        final response = await _supabase.storage.from('faces').list();
        final exists = response.any((item) => item.name == '$uid.jpg');

        if (exists) {
          final url = await _supabase.storage
              .from('faces')
.createSignedUrl('$uid.jpg', 604800); // 7 أيام بالثواني
          setState(() => _imageUrl = url);
        }
      } catch (e) {
        print('❌ Failed to get image: $e');
      }
    }
  }
  Future<void> _fetchCourses() async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) return;

  try {
    final courseLinks = await _supabase
        .from('student_courses')
        .select('course_id')
        .eq('student_id', userId);

    print('📦 Linked course IDs: $courseLinks');

    List<Map<String, dynamic>> fetchedCourses = [];

    for (var link in courseLinks) {
      final course = await _supabase
          .from('courses')
          .select('id, name')
          .eq('id', link['course_id'])
          .maybeSingle();

      if (course != null) {
        fetchedCourses.add(course);
      }
    }

    setState(() {
      _courses = fetchedCourses;
      _loading = false;
    });
  } catch (e) {
    print('❌ ERROR in fetchCourses: $e');
    setState(() => _loading = false);
  }
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
      drawer: Align(
  alignment: Alignment.centerLeft,
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: 340, 
   // maxHeight: 2000
    ),
    child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
             UserAccountsDrawerHeader(
  decoration: BoxDecoration(color: colorScheme.primary),
  currentAccountPicture: CircleAvatar(
    backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
    backgroundColor: Colors.white24,
    child: _imageUrl == null
        ? const Icon(Icons.person, size: 40, color: Colors.white)
        : null,
  ),
  accountName: Text(
    name.toString().toUpperCase(),
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  accountEmail: Text('$universityId | $email'),
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
                      final newLocale = context.locale.languageCode == 'ar'
                          ? const Locale('en')
                          : const Locale('ar');
                      context.setLocale(newLocale);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: Text(tr("change_password")),
                    onTap: () => Navigator.pushNamed(context, '/change-password'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: Text(tr("dark_mode")),
                    onTap: () => ThemeManager.toggleTheme(),
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(tr("logout")),
                onTap: () async {
                  await _supabase.auth.signOut();
                    if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),

  )),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(child: Text(tr("no_courses_found")))
              : RefreshIndicator(
                  onRefresh: _fetchCourses,
                  child: ListView.builder(
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
final course = _courses[index];
                      return ListTile(
title: Text(course['name']),
                        subtitle: Text(tr("course_options")),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentCourseStatsView(
                                courseId: course['id'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
              //  builder: (_) => ChooseVerificationMethodView(userId: '',),
              //
                builder: (_) =>  FaceRecognitionView(userId:  Supabase.instance.client.auth.currentUser!.id),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr("no_user_found"))),
            );
          }
        },
        tooltip: tr('scan_qr'),
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
