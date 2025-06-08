// this page helps admin to manage users, view their details and delete them
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/supabase_service.dart';
import 'package:http/http.dart' as http;

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final _supabase = Supabase.instance.client;
  List<User> _users = [];
  String _selectedRole = 'student';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await SupabaseService.admin.auth.admin.listUsers();
    final filtered = response
        .where((u) => u.userMetadata != null && u.userMetadata!['role'] == _selectedRole)
        .toList();
    if (mounted) {
      setState(() {
        _users = filtered;
      });
    }
  }

  Future<void> _deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://student-api-sgwe.onrender.com/delete_user/$id'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("user_deleted"))),
        );
        _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("delete_failed"))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("delete_failed"))),
      );
    }
  }

  void _showUserDetails(User user) async {
    final metadata = user.userMetadata ?? {};
    final universityId = metadata['student_id']?.toString() ??
        metadata['employee_id']?.toString() ??
        tr("no_id");

    String? imageUrl;

    try {
      imageUrl = await _supabase.storage
          .from('faces')
          .createSignedUrl('${user.id}.jpg', 60);
    } catch (_) {}

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(tr("user_details")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 40.r,
                ),
              ),
            SizedBox(height: 12.h),
            Text("${tr("university_id")}: $universityId"),
            Text("${tr("email")}: ${user.email ?? tr("not_available")}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr("close")),
          ),
        ],
      ),
    );
  }

  void _toggleLanguage() {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("manage_users")),
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: tr("change_language"),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            ToggleButtons(
              borderRadius: BorderRadius.circular(10.r),
              borderColor: Colors.grey,
              selectedColor: Colors.white,
              fillColor: colorScheme.primary,
              isSelected: [
                _selectedRole == 'student',
                _selectedRole == 'teacher',
              ],
              onPressed: (index) {
                final role = index == 0 ? 'student' : 'teacher';
                setState(() => _selectedRole = role);
                _fetchUsers();
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(tr("students"), style: TextStyle(fontSize: 16.sp)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(tr("teachers"), style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
            Divider(thickness: 1.2.h),
            Expanded(
              child: _users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (_, index) {
                        final user = _users[index];
                        final universityId = user.userMetadata?['student_id']?.toString() ??
                            user.userMetadata?['employee_id']?.toString() ??
                            tr("no_id");

                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            title: Text(
                              universityId,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            subtitle: Text(user.email ?? tr("no_email")),
                            trailing: PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              onSelected: (value) {
                                if (value == 'view') {
                                  _showUserDetails(user);
                                } else if (value == 'delete') {
                                  _deleteUser(user.id);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'view',
                                  child: Text(tr("view_details")),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(tr("delete_user")),
                                ),
                              ],
                            ),
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
