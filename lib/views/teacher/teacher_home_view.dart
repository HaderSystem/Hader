/* import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'qr_code_view.dart';
import 'package:flutter_application_2/widgets/custom_drawer.dart';
import 'package:easy_localization/easy_localization.dart';

class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({super.key});

  @override
  State<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final teacherId = _supabase.auth.currentUser?.id;
    if (teacherId == null) return;

    final response = await _supabase
        .from('courses')
        .select('*')
        .eq('teacher_id', teacherId);

    setState(() {
      _courses = response;
    });
  }

  void _createLecture(String courseId) async {
    final inserted = await _supabase
        .from('lectures')
        .insert({
          'course_id': courseId,
          'date': DateTime.now().toIso8601String().substring(0, 10),
        })
        .select()
        .single();

    final lectureId = inserted['id'];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lecture Created")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRCodeView(lectureId: lectureId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final email = user?.email ?? 'unknown@teacher.com';
    final metadata = user?.userMetadata ?? {};
    final name = metadata['name'] ?? 'No Name';
    final teacherId = metadata['teacher_id'] ?? 'Unknown ID';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
      ),

      /// ✅ Custom Drawer للمعلم
      drawer: CustomDrawer(
        name: name,
        universityId: teacherId,
        email: email,
        imageUrl: null, // ما في صورة للمعلم حالياً
      ),

      body: _courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  child: ListTile(
                    title: Text(course['name']),
                    trailing: ElevatedButton(
                      child: const Text("New Lecture"),
                      onPressed: () => _createLecture(course['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
 */
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/theme_provider.dart';
import 'qr_code_view.dart';

class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({super.key});

  @override
  State<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final teacherId = _supabase.auth.currentUser?.id;
    if (teacherId == null) return;

    final response = await _supabase
        .from('courses')
        .select('*')
        .eq('teacher_id', teacherId);

    setState(() {
      _courses = response;
    });
  }

  void _createLecture(String courseId) async {
    final inserted = await _supabase
        .from('lectures')
        .insert({
          'course_id': courseId,
          'date': DateTime.now().toIso8601String().substring(0, 10),
        })
        .select()
        .single();

    final lectureId = inserted['id'];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lecture Created")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRCodeView(lectureId: lectureId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final user = _supabase.auth.currentUser;
    final email = user?.email ?? 'unknown@teacher.com';
    final metadata = user?.userMetadata ?? {};
    final name = metadata['name'] ?? 'No Name';

    return Scaffold(
      appBar: AppBar(title: Text("Teacher Dashboard")),

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
              title: const Text("Settings"),
              children: [
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Change Password"),
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text("Toggle Theme"),
                  onTap: () => ThemeManager.toggleTheme(),
                ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("تسجيل الخروج"),
              onTap: () async {
                await _supabase.auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      body: _courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  child: ListTile(
                    title: Text(course['name']),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                      ),
                      child: const Text("New Lecture", style: TextStyle(color: Colors.white)),
                      onPressed: () => _createLecture(course['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
