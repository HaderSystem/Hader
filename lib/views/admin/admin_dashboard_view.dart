import 'package:flutter/material.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/manage-users'),
            child: const Text("Manage Users"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/manage-courses'),
            child: const Text("Manage Courses"),
          ),
          ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/assign-students'),
  child: const Text("Assign Students to Courses"),
),
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/attendance-report'),
  child: const Text("Attendance Report"),
),
ElevatedButton(
  onPressed: () => Navigator.pushNamed(context, '/create-user'),
  child: const Text("إنشاء مستخدم جديد"),
),



        ],
      ),
    );
  }
}
