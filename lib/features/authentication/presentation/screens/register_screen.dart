import 'package:flutter/material.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/gradient_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedLevel = 'N5';
  bool _obscurePassword = true;
  bool _isLoading = false;
  final List<String> _japaneseLevels = ['N5', 'N4'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    _authController.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      initialLevel: _selectedLevel,
      onLoading: () => setState(() => _isLoading = true),
      onSuccess: () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      },
      onError: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/lo.png', height: 100, width: 100, fit: BoxFit.contain),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration('Họ và tên', Icons.badge_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Địa chỉ Email', Icons.email_outlined),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _usernameController,
                      decoration: _inputDecoration('Tên tài khoản', Icons.account_circle_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng tạo Username' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('Mật khẩu', Icons.lock_outline_rounded).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primary),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu phải từ 6 ký tự' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('Xác nhận mật khẩu', Icons.lock_reset_outlined),
                      validator: (v) => (v != _passwordController.text) ? 'Mật khẩu không khớp' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      dropdownColor: Colors.white,
                      decoration: _inputDecoration('Trình độ tiếng Nhật', Icons.translate_outlined),
                      items: _japaneseLevels.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(color: AppColors.primary)))).toList(),
                      onChanged: (v) => setState(() => _selectedLevel = v!),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: _isLoading ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(onPressed: _handleRegister, child: const Text('Đăng ký ngay')),
                    ),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đã có tài khoản? Đăng nhập')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.primary),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 2.0)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}