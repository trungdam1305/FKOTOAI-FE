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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2B5C92)),
        title: const Text('Khôi phục mật khẩu', style: TextStyle(color: Color(0xFF2B5C92))),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF97CADB),
              Color(0xFFD6E8EE),
              Color(0xFFF8F8F8),
              Colors.white,
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Center(
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
                      Image.asset('assets/images/lo.png', height: 100, width: 100, fit: BoxFit.contain),
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
                            backgroundColor: const Color(0xFF2B5C92),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            _currentStep == 0
                                ? 'Gửi mã xác thực'
                                : _currentStep == 1
                                ? 'Xác thực tài khoản'
                                : 'Xác nhận đặt lại mật khẩu',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
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
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        const Text(
          'Nhập email đã đăng ký của bạn. Hệ thống sẽ gửi một mã xác thực OTP.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF2B5C92), fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Địa chỉ Email đăng ký', Icons.email_outlined),
          validator: (value) => (value == null || !value.contains('@')) ? 'Email không hợp lệ' : null,
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        const Text(
          'Vui lòng kiểm tra hộp thư đến và nhập mã OTP vào ô dưới đây:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF2B5C92), fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8, color: Color(0xFF2B5C92)),
          decoration: _inputDecoration('Mã xác thực OTP', Icons.numbers_outlined).copyWith(
            hintText: '000000',
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      children: [
        const Text(
          'Tài khoản hợp lệ! Vui lòng thiết lập mật khẩu mới.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF2B5C92), fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Color(0xFF2B5C92)),
          decoration: _inputDecoration('Mật khẩu mới', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF2B5C92)),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Color(0xFF2B5C92)),
          decoration: _inputDecoration('Xác nhận mật khẩu mới', Icons.lock_reset_outlined),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF2B5C92)),
      prefixIcon: Icon(icon, color: const Color(0xFF2B5C92)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2B5C92), width: 1.5)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2B5C92), width: 2.0)),
      border: const OutlineInputBorder(),
    );
  }
}