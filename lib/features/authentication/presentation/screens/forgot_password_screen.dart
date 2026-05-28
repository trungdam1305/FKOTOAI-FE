import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mã OTP đã được gửi đến ${_emailController.text}'), backgroundColor: Colors.green),
    );

    setState(() {
      _currentStep = 1;
    });
  }

  void _handleVerifyOTP() async {
    if (_otpController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ mã OTP'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Xác thực tài khoản thành công!'), backgroundColor: Colors.green),
    );

    setState(() {
      _currentStep = 2;
    });
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.'), backgroundColor: Colors.green),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khôi phục mật khẩu'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _currentStep == 0
                      ? Icons.mark_email_read_outlined
                      : _currentStep == 1
                      ? Icons.lock_clock_outlined
                      : Icons.published_with_changes_rounded,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                if (_currentStep == 0) _buildEmailStep(),
                if (_currentStep == 1) _buildOtpStep(),
                if (_currentStep == 2) _buildNewPasswordStep(),

                const SizedBox(height: 32),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _currentStep == 0
                      ? _handleSendOTP
                      : _currentStep == 1
                      ? _handleVerifyOTP
                      : _handleResetPassword,
                  child: Text(
                    _currentStep == 0
                        ? 'Gửi mã xác thực'
                        : _currentStep == 1
                        ? 'Xác thực tài khoản'
                        : 'Xác nhận đặt lại mật khẩu',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Input Registered Email & Send Link
  Widget _buildEmailStep() {
    return Column(
      children: [
        const Text(
          'Nhập email đã đăng ký của bạn. Hệ thống sẽ gửi một mã xác thực OTP để xác minh quyền sở hữu tài khoản.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ Email đăng ký',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Vui lòng nhập Email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Email không đúng định dạng';
            return null;
          },
        ),
      ],
    );
  }

  //Input OTP & Verify Account
  Widget _buildOtpStep() {
    return Column(
      children: [
        Text(
          'Mã xác thực đã được gửi. Vui lòng kiểm tra hộp thư đến và nhập mã OTP vào ô dưới đây:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blueGrey[700], fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
          decoration: const InputDecoration(
            labelText: 'Mã xác thực OTP',
            hintText: '000000',
            counterText: '',
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã gửi lại mã OTP mới!')),
            );
          },
          child: const Text('Gửi lại mã OTP (Resend OTP)', style: TextStyle(color: Colors.blue)),
        )
      ],
    );
  }

  //Create New Password & Confirm Password
  Widget _buildNewPasswordStep() {
    return Column(
      children: [
        const Text(
          'Tài khoản hợp lệ! Vui lòng thiết lập mật khẩu mới có độ bảo mật cao cho tài khoản của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),

        //  1: Create New Password
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới (New Password)',
            prefixIcon: const Icon(Icons.lock_outline),

            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) => (value == null || value.length < 6) ? 'Mật khẩu phải chứa ít nhất 6 ký tự' : null,
        ),
        const SizedBox(height: 16),

        //  2: Confirm Password Reset
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: const InputDecoration(
            labelText: 'Xác nhận lại mật khẩu mới',
            prefixIcon: Icon(Icons.lock_reset_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập lại mật khẩu';
            if (value != _newPasswordController.text) return 'Mật khẩu xác nhận không trùng khớp!';
            return null;
          },
        ),
      ],
    );
  }
}