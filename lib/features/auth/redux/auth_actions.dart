import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpRequested {
  const SignUpRequested(this.email, this.password);

  final String email;

  final String password;
}

class SignInRequested {
  const SignInRequested(this.email, this.password);

  final String email;

  final String password;
}

class SignOutRequested {
  const SignOutRequested();
}

class AuthSessionChanged {
  const AuthSessionChanged(this.session);

  final Session? session;
}

class AuthSucceeded {
  const AuthSucceeded(this.session);

  final Session? session;
}

class AuthFailed {
  const AuthFailed(this.message);

  final String message;
}

class AuthStreamFailed {
  const AuthStreamFailed(this.message);

  final String message;
}

class EmailConfirmationRequired {
  const EmailConfirmationRequired();
}

class AuthFeedbackCleared {
  const AuthFeedbackCleared();
}
