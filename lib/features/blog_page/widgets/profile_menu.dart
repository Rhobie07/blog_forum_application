import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.isSignedIn,
    this.displayName,
    this.onLogin,
    this.onLogout,
  });

  final bool isSignedIn;
  final String? displayName;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isSignedIn) {
      return FilledButton.tonal(
        onPressed: onLogin,
        child: const Text('Sign in'),
      );
    }

    final name = displayName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.primary.withAlpha(25),
          child: Text(
            initial,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(onPressed: onLogout, child: const Text('Logout')),
      ],
    );
  }
}
