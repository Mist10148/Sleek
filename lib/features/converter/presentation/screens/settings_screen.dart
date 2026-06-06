import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Lightweight settings / about screen. Kept minimal for v1; future options
/// (default format, theme mode, default directory) hook in here.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text(AppConstants.appName),
            subtitle: Text(AppConstants.appTagline),
          ),
          const ListTile(
            leading: Icon(Icons.tag_rounded),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'For personal use only. Respect YouTube\'s Terms of Service and '
              'copyright law — only download content you own or have permission '
              'to download.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
