import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  void _toggleLanguage(BuildContext context) {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002D62),
        title: Text(tr("admin_dashboard")),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _toggleLanguage(context),
            tooltip: tr("change_language"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildDashboardButton(
              context,
              label: tr("manage_users"),
              icon: Icons.people,
              route: '/manage-users',
            ),
            _buildDashboardButton(
              context,
              label: tr("manage_courses"),
              icon: Icons.menu_book,
              route: '/manage-courses',
            ),
            _buildDashboardButton(
              context,
              label: tr("assign_students"),
              icon: Icons.group_add,
              route: '/assign-students',
            ),
            _buildDashboardButton(
              context,
              label: tr("attendance_report"),
              icon: Icons.bar_chart,
              route: '/attendance-report',
            ),
            _buildDashboardButton(
              context,
              label: tr("create_user"),
              icon: Icons.person_add,
              route: '/select-user-type-to-create',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF002D62),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
