import 'package:flutter/material.dart';

import '../../domain/entities/media_format.dart';

/// Quality chips for the current format. Shows a friendly empty state when no
/// options are available (e.g. video with no muxed streams).
class QualitySelector extends StatelessWidget {
  const QualitySelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<QualityOption> options;
  final QualityOption? selected;
  final ValueChanged<QualityOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (options.isEmpty) {
      return Text(
        'No quality options available for this format.',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          ChoiceChip(
            selected: option == selected,
            onSelected: (_) => onChanged(option),
            label: Text(option.label),
            avatar: option.subtitle != null
                ? null
                : const Icon(Icons.high_quality_rounded, size: 18),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: option == selected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurface,
            ),
            tooltip: option.subtitle,
          ),
      ],
    );
  }
}
