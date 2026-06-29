import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart';  // ✅ correct import

// If you have separate admin/user screens, import them here:
// import '../screens/admin_dashboard.dart';
// import '../screens/user_dashboard.dart';

class DashboardWrapper extends StatefulWidget {
  const DashboardWrapper({super.key});

  @override
  State<DashboardWrapper> createState() => _DashboardWrapperState();
}

class _DashboardWrapperState extends State<DashboardWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _role = 'user';
  bool _isLoading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _role = data['role'] ?? 'user';
          _userName = data['name'] ?? 'User';
          _isLoading = false;
        });
      } else {
        // If user document doesn't exist, force logout (should not happen)
        await _auth.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _role = 'user';
        _userName = 'User';
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // You can conditionally return different screens based on role
    // For now, we show a unified dashboard with role-specific content.
    return Scaffold(
      appBar: AppBar(
        title: Text('${_role.toUpperCase()} Dashboard'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $_userName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'You are logged in as: $_role',
              style: const TextStyle(fontSize: 18, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 40),
            // Role-specific content
            if (_role == 'admin') ...[
              const Text(
                'Admin Panel: Manage users, inventory, etc.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Admin-specific buttons or widgets
              ElevatedButton(
                onPressed: () {
                  // Navigate to admin management screen
                },
                child: const Text('Manage Users'),
              ),
            ] else ...[
              const Text(
                'User Panel: View your profile, requests, etc.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to user profile
                },
                child: const Text('View Profile'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}