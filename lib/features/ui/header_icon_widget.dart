import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeaderIconWidget extends StatelessWidget {
  const HeaderIconWidget({super.key, this.theme});

  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/blogPage'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories, color: theme!.colorScheme.primary, size: 24),
          const SizedBox(width: 10),
          Text(
            'The Forum',
            style: theme!.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
