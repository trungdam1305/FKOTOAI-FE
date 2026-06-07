import 'package:flutter/material.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();

  // Input Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  String _selectedLevel = 'N5'; // Choose Initial Level
  bool _obscurePassword = true; // Toggle Password Visibility
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký tài khoản thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      },
      onError: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add_alt_1_outlined, size: 80, color: Colors.blue),
                const SizedBox(height: 24),

                // 1. Input Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên (Full Name)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                ),
                const SizedBox(height: 16),

                // 2. Input Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập Email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Email không đúng định dạng';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Create Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên tài khoản (Username)',
                    prefixIcon: Icon(Icons.account_circle_outlined),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng tạo Username' : null,
                ),
                const SizedBox(height: 16),

                // 4. Create Password & Toggle Password Visibility
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu (Password)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => (value == null || value.length < 6) ? 'Mật khẩu phải từ 6 ký tự trở lên' : null,
                ),
                const SizedBox(height: 16),

                // 5. Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu (Confirm Password)',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng xác nhận lại mật khẩu';
                    if (value != _passwordController.text) return 'Mật khẩu nhập lại không trùng khớp!';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown level
                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Trình độ tiếng Nhật ban đầu',
                    prefixIcon: Icon(Icons.translate_outlined),

                  ),
                  items: _japaneseLevels.map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedLevel = newValue);
                    }
                  },
                ),
                const SizedBox(height: 32),

                // 6. Register Account Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _handleRegister,

                  child: const Text('Đăng ký ngay'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}