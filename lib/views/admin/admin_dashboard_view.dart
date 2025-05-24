import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/theme_provider.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(tr("admin_dashboard")),
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
         /*    _buildDashboardButton(
              context,
              label: tr("attendance_report"),
              icon: Icons.bar_chart,
              route: '/attendance-report',
            ), */
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

  Widget _buildDashboardButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
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
