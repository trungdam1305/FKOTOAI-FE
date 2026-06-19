import 'package:flutter/material.dart';
import 'package:bim/core/theme/app_colors.dart';
import 'package:bim/core/theme/gradient_background.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:bim/features/authentication/presentation/screens/register_screen.dart';
import 'package:bim/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:bim/features/main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  final _authController = AuthController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    _authController.login(
      email: _idController.text.trim(),
      password: _passController.text.trim(),
      onLoading: () => setState(() => _isLoading = true),
      onSuccess: (token) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      },
      onError: (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e), backgroundColor: Colors.red));
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
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/lo.png', height: 90, width: 90, fit: BoxFit.contain),
                    const SizedBox(width: 12),
                    const Text('FKOTOAI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2B5C92), letterSpacing: 1.2,),
                    ),
                  ],
                  ),

                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _idController,
                      style: const TextStyle(color: AppColors.primary),
                      decoration: _inputDecoration('Email', Icons.person_outline),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập Email' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppColors.primary),
                      decoration: _inputDecoration('Mật khẩu', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primary),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!), activeColor: AppColors.primary),
                            const Text('Remember me', style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                          child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(onPressed: _handleLogin, child: const Text('Đăng nhập')),
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Chưa có tài khoản? Đăng ký ngay', style: TextStyle(color: AppColors.primary)),
                    ),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }
}