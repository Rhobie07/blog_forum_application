import 'package:biog_forum_application/features/auth/state/auth_notifier.dart';
import 'package:biog_forum_application/features/ui/header_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthNotifier>().clearFeedback();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthNotifier>().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _goRegister() {
    ScaffoldMessenger.of(context).clearSnackBars();
    context.read<AuthNotifier>().clearFeedback();
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.select<AuthNotifier, ({bool loading, String? error})>(
      (notifier) =>
          (loading: notifier.state.loading, error: notifier.state.error),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 500;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: Row(children: [HeaderIconWidget(theme: theme)]),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: narrow ? double.infinity : 400,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(narrow ? 24 : 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome back',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Sign in to your account',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),

                            const SizedBox(height: 32),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Please enter your email'
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                            ),

                            if (auth.error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withAlpha(12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 18,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        auth.error!,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            FilledButton(
                              onPressed: auth.loading ? null : _login,
                              child: auth.loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sign in'),
                            ),

                            const SizedBox(height: 16),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: theme.textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: _goRegister,
                                  child: const Text('Create one'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
