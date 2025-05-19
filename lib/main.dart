import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/student_attendance_history_view.dart';
import 'package:flutter_application_2/views/Students/student_home_view.dart';
import 'package:flutter_application_2/views/admin/admin_dashboard_view.dart';
import 'package:flutter_application_2/views/admin/attendance_report_view.dart';
import 'package:flutter_application_2/views/admin/create_teacher_view.dart';
import 'package:flutter_application_2/views/admin/create_student_view.dart';
import 'package:flutter_application_2/views/admin/manage_courses_view.dart';
import 'package:flutter_application_2/views/admin/manage_users_view.dart';
import 'package:flutter_application_2/views/admin/select_user_type_to_create.dart';
import 'package:flutter_application_2/views/teacher/teacher_home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'views/login_view.dart';
import 'views/Students/face_recognition_view.dart';
import 'views/Students/qr_scanner_view.dart';
import 'views/Students/student_register_view.dart';
import 'views/admin/assign_students_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gnorslgqghumwmgoqwhk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3JzbGdxZ2h1bXdtZ29xd2hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMzA1MzUsImV4cCI6MjA2MDgwNjUzNX0.cXIYgB07hbk7r5Jx9niq1CxNiaK7Ddx8dqkPAQSwt0o',
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'lib/assets/lang',
      fallbackLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance System',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/student': (context) => const StudentHomeView(),
        '/teacher': (context) => const TeacherHomeView(),
        '/admin': (context) => const AdminDashboardView(),
        '/manage-users': (context) => const ManageUsersView(),
        '/assign-students': (context) => const AssignStudentsView(),
        '/attendance-report': (context) => const AttendanceReportView(),
        '/create-student': (context) => const CreateStudentView(),
        '/face-verification': (context) => FaceRecognitionView(userId: Supabase.instance.client.auth.currentUser!.id),
        '/qr-scanner': (context) => const QRScannerView(),
        '/attendance-history': (context) => const StudentAttendanceHistoryView(),
        '/register-student': (context) => const StudentRegisterView(),
        '/manage-courses': (context) => const ManageCoursesView(),
        '/select-user-type-to-create': (context) => const CreateUserTypeView(),
        '/create-teacher': (context) => const CreateTeacherView(),


      },
    );
  }
}


/* import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/student_attendance_history_view.dart';
import 'package:flutter_application_2/views/Students/student_home_view.dart';
import 'package:flutter_application_2/views/admin/admin_dashboard_view.dart';
import 'package:flutter_application_2/views/admin/attendance_report_view.dart';
import 'package:flutter_application_2/views/admin/create_user_view.dart';
import 'package:flutter_application_2/views/admin/manage_courses_view.dart';
import 'package:flutter_application_2/views/admin/manage_users_view.dart';
import 'package:flutter_application_2/views/teacher/teacher_home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';


import 'views/login_view.dart';
import 'views/Students/face_recognition_view.dart';
import 'views/Students/qr_scanner_view.dart';
import 'views/Students/student_register_view.dart';
import 'views/admin/assign_students_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gnorslgqghumwmgoqwhk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3JzbGdxZ2h1bXdtZ29xd2hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMzA1MzUsImV4cCI6MjA2MDgwNjUzNX0.cXIYgB07hbk7r5Jx9niq1CxNiaK7Ddx8dqkPAQSwt0o',
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance System',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/student': (context) => const StudentHomeView(),
        '/teacher': (context) => const TeacherHomeView(),
        '/admin': (context) => const AdminDashboardView(),
        '/manage-users': (context) => const ManageUsersView(),
        '/assign-students': (context) => const AssignStudentsView(courseId: ''),
        '/attendance-report': (context) => const AttendanceReportView(),
        '/create-user': (context) => const CreateStudentView(),
        '/face-verification': (context) =>
            FaceRecognitionView(userId: Supabase.instance.client.auth.currentUser!.id),
        '/qr-scanner': (context) => const QRScannerView(),
        '/attendance-history': (context) => const StudentAttendanceHistoryView(),
        '/register-student': (context) => const StudentRegisterView(),
        '/manage-courses': (context) => const ManageCoursesView(),
      },
    );
  }
}
 */