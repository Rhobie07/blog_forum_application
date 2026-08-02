import 'package:flutter/widgets.dart';

class LoginViewModel {
  const LoginViewModel({
    required this.loading,
    this.error,
    required this.onLogin,
  });

  final bool loading;

  final String? error;

  final VoidCallback onLogin;
}

class RegisterViewModel {
  const RegisterViewModel({
    required this.loading,
    this.error,
    required this.emailConfirmationRequired,
    required this.onRegister,
    required this.navigateToLogin,
  });

  final bool loading;

  final String? error;

  final bool emailConfirmationRequired;

  final VoidCallback onRegister;

  final VoidCallback navigateToLogin;
}
