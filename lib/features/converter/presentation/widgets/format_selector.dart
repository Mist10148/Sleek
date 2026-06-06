import 'package:flutter/material.dart';

import '../../domain/entities/media_format.dart';

/// MP3 / MP4 segmented choice.
class FormatSelector extends StatelessWidget {
  const FormatSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MediaFormat selected;
  final ValueChanged<MediaFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final format in MediaFormat.values) ...[
          Expanded(child: _FormatTile(
            format: format,
            selected: format == selected,
            onTap: () => onChanged(format),
          )),
          if (format != MediaFormat.values.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({
    required this.format,
    required this.selected,
    required this.onTap,
  });

  final MediaFormat format;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final IconData icon =
        format.isAudio ? Icons.music_note_rounded : Icons.movie_rounded;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              format.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              format.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
