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
    final double logoSize = screenWidth > 600 ? 120 : screenWidth * 0.23;
    final double fontSize = screenWidth > 600 ? 32 : screenWidth * 0.07;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Đăng nhập'),
      // ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/lo.png',
                      height: logoSize,
                      width: logoSize,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Text(
                      'FKOTOAI',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 1. Username/Email Input
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Tên tài khoản hoặc Email',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập Username hoặc Email' : null,
                ),
                const SizedBox(height: 16),

                // 2. Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                ),
                const SizedBox(height: 8),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) => setState(() => _rememberMe = value ?? false),
                        ),
                        const Text('Remember me', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    // Navigate to Forgot Password
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),


                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _handleLogin,

                  child: const Text('Đăng nhập'),
                ),
                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1, endIndent: 10, indent: 10)),
                    Text("HOẶC", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    Expanded(child: Divider(thickness: 1, indent: 10, endIndent: 10)),
                  ],
                ),
                const SizedBox(height: 20),

                _isGoogleLoading
                    ? const CircularProgressIndicator()
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenWidth = MediaQuery.of(context).size.width;
                    final double buttonWidth = screenWidth > 600 ? 400 : screenWidth * 0.85;

                    return SizedBox(
                      width: buttonWidth,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _handleGoogleLogin,
                        icon: Image.asset(
                          'assets/images/img.png',
                          height: 22,
                          width: 22,
                          fit: BoxFit.contain,
                        ),
                        label: const Flexible(
                          child: Text(
                            'Đăng nhập với Google',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Colors.grey),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký ngay', style: TextStyle(color: Colors.blueGrey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}