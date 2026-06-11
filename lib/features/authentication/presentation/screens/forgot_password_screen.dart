import 'package:flutter/material.dart';
import 'package:bim/features/authentication/presentation/controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _authController = AuthController();
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

  void _handleSendOTP() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;

    _authController.sendPasswordResetOTP(
      email: _emailController.text.trim(),
      onLoading: () => setState(() => _isLoading = true),
      onSuccess: () {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mã OTP đã được gửi thành công!'),
              backgroundColor: Colors.green
          ),
        );

        if (_currentStep == 0) {
          setState(() => _currentStep = 1);
        }
      },
      onError: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  void _handleVerifyOTP() {
    if (_otpController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP quá ngắn!'), backgroundColor: Colors.orange),
      );
      return;
    }

    _authController.verifyResetOTP(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
      onLoading: () => setState(() => _isLoading = true),
      onSuccess: () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xác thực OTP thành công!'), backgroundColor: Colors.green),
        );
        setState(() => _currentStep = 2);
      },
      onError: (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }

  void _handleResetPassword() {

    if (!_formKey.currentState!.validate()) return;


    _authController.confirmPasswordReset(
      newPassword: _newPasswordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      onLoading: () => setState(() => _isLoading = true),
      onSuccess: () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lại mật khẩu thành công!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text('Khôi phục mật khẩu')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/lo.png',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    if (_currentStep == 0) _buildEmailStep(),
                    if (_currentStep == 1) _buildOtpStep(),
                    if (_currentStep == 2) _buildNewPasswordStep(),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _currentStep == 0
                            ? _handleSendOTP
                            : _currentStep == 1
                            ? _handleVerifyOTP
                            : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _currentStep == 0
                              ? 'Gửi mã xác thực'
                              : _currentStep == 1
                              ? 'Xác thực tài khoản'
                              : 'Xác nhận đặt lại mật khẩu',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
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
            border: OutlineInputBorder(),
          ),
          validator: (value) => (value == null || !value.contains('@')) ? 'Email không hợp lệ' : null,
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        const Text(
          'Mã xác thực đã được gửi. Vui lòng kiểm tra hộp thư đến và nhập mã OTP vào ô dưới đây:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blueGrey, fontSize: 14),
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
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      children: [
        const Text(
          'Tài khoản hợp lệ! Vui lòng thiết lập mật khẩu mới có độ bảo mật cao.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: const InputDecoration(
            labelText: 'Xác nhận mật khẩu mới',
            prefixIcon: Icon(Icons.lock_reset_outlined),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}