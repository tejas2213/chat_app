import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../controllers/auth_controller.dart';
import '../widgets/phone_input_widget.dart';
import '../widgets/auth_button_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final String _countryCode = '+91';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) => AuthController.handleAuthState(context, state),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildPhoneInput(),
                const SizedBox(height: 30),
                _buildSendOtpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/logo.png', height: 160),
        const Text(
          'Chat App',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your phone number to get started',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return PhoneInputWidget(
      controller: _phoneController,
      countryCode: _countryCode,
      onChanged: _handlePhoneChange,
      validator: _validatePhoneNumber,
    );
  }

  Widget _buildSendOtpButton() {
    return AuthButtonWidget(
      text: 'Send OTP',
      onPressed: _handleSendOtp,
    );
  }

  void _handlePhoneChange(String value) {
    if (value.length > 10) {
      _phoneController.text = value.substring(0, 10);
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length),
      );
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length != 10) {
      return 'Please enter 10-digit phone number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Please enter valid Indian phone number';
    }
    return null;
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      final fullPhoneNumber = '$_countryCode${_phoneController.text}';
      AuthController.sendOtp(context, fullPhoneNumber);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}