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
  late Future<List<user_model.User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  void _loadUsers() {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    _usersFuture = fs.getAllUsers();
    setState(() {});
  }

  Future<void> _toggleAdmin(user_model.User u) async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final newRole = u.role == user_model.UserRole.admin ? 'user' : 'admin';
    try {
      await fs.updateUserProfile(u.id, {'role': newRole});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated ${u.email} -> $newRole')));
      _loadUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: FutureBuilder<List<user_model.User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final u = users[i];
              return ListTile(
                leading: CircleAvatar(
                    child: Text(
                        u.name.isNotEmpty ? u.name[0].toUpperCase() : '?')),
                title: Text(u.name),
                subtitle: Text(u.email),
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
