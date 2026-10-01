// lib/screens/admin_users_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// AdminUsersScreen | පරිශීලකයන් කළමනාකරණ තිරය (Admin User Management Screen)
// Lists all registered users and allows toggling the 'admin' role.
// ලියාපදිංචි පරිශීලකයන් සියල්ල ලැයිස්තු කර 'admin' භූමිකාව ටොගල් කිරීමට ඉඩ දෙයි.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/user.dart' as user_model;

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // Holds the asynchronous list of users from Firestore
  // Firestore හි ඇති පරිශීලකයන් ලයිස්තුව async ලෙස ලබා ගනී
  late Future<List<user_model.User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    // Load users after first frame to access BuildContext safely
    // BuildContext ආරක්ෂිතව ලබා ගැනීමට පළමු ෆ්‍රේමයෙන් පසු users ලෝඩ් කරයි
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  // ─── _loadUsers: Fetch all users from Firestore | Firestore හි සියළු පරිශීලකයන් ලොඩ් කරයි ──
  void _loadUsers() {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    _usersFuture = fs.getAllUsers();
    setState(() {}); // Trigger FutureBuilder rebuild | FutureBuilder නැවත ගොඩනැගීමට
  }

  // ─── _toggleAdmin: Flip user role between 'admin' and 'user' ─────────────
  // _toggleAdmin: 'admin' සහ 'user' අතර භූමිකාව (role) මාරු කරයි
  Future<void> _toggleAdmin(user_model.User u) async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    // If current role is admin, demote to user; otherwise promote to admin
    // දැනට admin නම් user ලෙස හිතයි; නැතිනම් admin ලෙස උසස් කරයි
    final newRole = u.role == user_model.UserRole.admin ? 'user' : 'admin';
    try {
      await fs.updateUserProfile(u.id, {'role': newRole});
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated ${u.email} -> $newRole')));
      _loadUsers(); // Reload the list to reflect changes | වෙනස් කිරීම් පෙන්වීමට ලයිස්තුව නැවත ලෝඩ් කරයි
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      // FutureBuilder handles loading, error, and data states
      // FutureBuilder loading, error, සහ data තත්ව හැසිරවීම කළමනාකරණය කරයි
      body: FutureBuilder<List<user_model.User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          // Show spinner while waiting | රැඳී සිටින විට spinner පෙන්වයි
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show error if failed | අසාර්ථක නම් දෝෂය (error) පෙන්වයි
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          // Show empty state message | පරිශීලකයන් නොමැතිනම් හිස් state පෙන්වයි
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          // User list with role toggle button | භූමිකාව ටොගල් බොත්තම සහිත පරිශීලක ලැයිස්තුව
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final u = users[i];
              return ListTile(
                // Avatar with first letter of user name | නමේ පළමු අකුරෙන් Avatar
                leading: CircleAvatar(
                    child: Text(
                        u.name.isNotEmpty ? u.name[0].toUpperCase() : '?')),
                title: Text(u.name),
                subtitle: Text(u.email),
                // Toggle admin role button | Admin භූමිකාව ටොගල් කිරීමේ බොත්තම
                trailing: ElevatedButton(
                  onPressed: () => _toggleAdmin(u),
                  child: Text(u.role == user_model.UserRole.admin
                      ? 'Revoke Admin'
                      : 'Make Admin'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
