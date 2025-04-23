import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/student_attendance_history_view.dart';
import 'package:flutter_application_2/views/Students/student_home_view.dart';
import 'package:flutter_application_2/views/admin/admin_dashboard_view.dart';
import 'package:flutter_application_2/views/admin/attendance_report_view.dart';
import 'package:flutter_application_2/views/admin/create_user_view.dart';
import 'package:flutter_application_2/views/admin/manage_users_view.dart';
import 'package:flutter_application_2/views/teacher/teacher_home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login_view.dart';
import 'views/Students/face_verification_view.dart';
import 'views/Students/qr_scanner_view.dart';
import 'package:flutter_application_2/views/Students/student_register_view.dart';

//import 'views/admin/manage_courses_view.dart';

import 'views/admin/assign_students_view.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
  
    url: 'https://gnorslgqghumwmgoqwhk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3JzbGdxZ2h1bXdtZ29xd2hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMzA1MzUsImV4cCI6MjA2MDgwNjUzNX0.cXIYgB07hbk7r5Jx9niq1CxNiaK7Ddx8dqkPAQSwt0o',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance System',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),

         '/student': (context) => const StudentHomeView(),
  '/teacher': (context) => const TeacherHomeView(),
  '/admin': (context) => const AdminDashboardView(),
  '/manage-users': (context) => const ManageUsersView(),
  '/assign-students': (context) => const AssignStudentsView(),
'/attendance-report': (context) => const AttendanceReportView(),
'/create-user': (context) => const CreateUserView(),

 '/face-verification': (context) => FaceVerificationView(userId: Supabase.instance.client.auth.currentUser!.id),
  '/qr-scanner': (context) => const QRScannerView(),
  '/attendance-history': (context) => const StudentAttendanceHistoryView(),
'/register-student': (context) => const StudentRegisterView(),


      },
    );
  }
}
