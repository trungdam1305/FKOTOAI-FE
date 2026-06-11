import 'package:flutter/material.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:bim/features/authentication/presentation/screens/register_screen.dart';
import 'package:bim/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:bim/features/main/main_screen.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    _authController.login(
      email: _identifierController.text.trim(),
      password: _passwordController.text.trim(),
      onLoading: () => setState(() => _isLoading = true),
      onSuccess: (token) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thành công!'), backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
      onError: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  // Login w Google
  void _handleGoogleLogin() {
    _authController.loginWithGoogle(
      onLoading: () => setState(() => _isGoogleLoading = true),
      onSuccess: (googleToken) {
        setState(() => _isGoogleLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Đăng nhập Google thành công!'),
              backgroundColor: Colors.blue
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
      onError: (error) {
        setState(() => _isGoogleLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
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
                        Image.asset('assets/images/lo.png', height: 80, width: 80, fit: BoxFit.contain),
                        const SizedBox(width: 12),
                        const Text(
                          'FKOTOAI',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 1. Username
                    TextFormField(
                      controller: _identifierController,
                      decoration: const InputDecoration(
                        labelText: 'Tên tài khoản hoặc Email',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập Username' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                    ),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v ?? false)),
                            const Text('Remember me'),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Login Button (full width)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("HOẶC")),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Google Login Button
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 50,
                    //   child: OutlinedButton.icon(
                    //     onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                    //     icon: Image.asset('assets/images/img.png', height: 22, width: 22),
                    //     label: const Text('Đăng nhập với Google', style: TextStyle(color: Colors.black87)),
                    //     style: OutlinedButton.styleFrom(
                    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: const Text('Chưa có tài khoản? Đăng ký ngay'),
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
}