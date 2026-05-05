import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedRole = 'commuter';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Create Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))
                    .animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 8),
                Text('Join LostLink to report and recover lost items',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.isEmpty ? 'Enter name' : null),
                      const SizedBox(height: 16),
                      TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v == null || v.isEmpty ? 'Enter email' : null),
                      const SizedBox(height: 16),
                      TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)), validator: (v) => v == null || v.isEmpty ? 'Enter phone' : null),
                      const SizedBox(height: 16),
                      TextFormField(controller: _passCtrl, obscureText: _obscure, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outlined), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscure = !_obscure))), validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Account Type', prefixIcon: Icon(Icons.badge_outlined)),
                        items: const [
                          DropdownMenuItem(value: 'commuter', child: Text('Commuter (Default)')),
                          DropdownMenuItem(value: 'officer', child: Text('Station Officer')),
                          DropdownMenuItem(value: 'admin', child: Text('System Admin')),
                        ],
                        onChanged: (v) => setState(() => _selectedRole = v!),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: auth.isLoading ? null : _register, child: auth.isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Account'))),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)), TextButton(onPressed: () => Navigator.pop(context), child: const Text('Sign In'))]),
                    ]),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthService>().register(
      name: _nameCtrl.text.trim(), 
      email: _emailCtrl.text.trim(), 
      phone: _phoneCtrl.text.trim(), 
      password: _passCtrl.text.trim(),
      role: _selectedRole, // Pass the selected role
    );
  }
}
