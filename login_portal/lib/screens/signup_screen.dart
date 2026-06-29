import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  String _selectedRole = 'user';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Password strength flags
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final pwd = _passwordController.text;
    setState(() {
      _hasMinLength = pwd.length >= 8;
      _hasUppercase = pwd.contains(RegExp(r'[A-Z]'));
      _hasLowercase = pwd.contains(RegExp(r'[a-z]'));
      _hasDigit = pwd.contains(RegExp(r'[0-9]'));
      _hasSpecial = pwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordStrong =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasDigit && _hasSpecial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // NIC
                TextFormField(
                  controller: _nicController,
                  decoration: const InputDecoration(
                    labelText: 'NIC (e.g., 123456789V or 12 digits)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your NIC';
                    }
                    if (!RegExp(r'^[0-9]{9}[Vv]$|^[0-9]{12}$').hasMatch(value)) {
                      return 'Enter a valid NIC (9 digits + V or 12 digits)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mobile
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!_isPasswordStrong) {
                      return 'Password is not strong enough';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Password strength indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStrengthItem('At least 8 characters', _hasMinLength),
                    _buildStrengthItem('At least one uppercase letter', _hasUppercase),
                    _buildStrengthItem('At least one lowercase letter', _hasLowercase),
                    _buildStrengthItem('At least one digit', _hasDigit),
                    _buildStrengthItem('At least one special character', _hasSpecial),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],

                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthItem(String label, bool satisfied) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.cancel,
          color: satisfied ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: satisfied ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppUser? user = await _auth.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        nic: _nicController.text.trim(),
        mobile: _mobileController.text.trim(),
        role: _selectedRole,
      );

      if (user != null && mounted) {
        if (user.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/user-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = 'Sign-up failed. Please try again.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _nicController.dispose();
    _mobileController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    super.dispose();
  }
}