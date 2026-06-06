import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/models/download_task.dart';

/// Live progress: a bar plus %, transferred size, speed, ETA and elapsed time.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.progress, required this.label});

  final DownloadProgress progress;

  /// e.g. "Downloading MP4 · 720p"
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool indeterminate = progress.totalBytes <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(
                  indeterminate
                      ? Formatters.fileSize(progress.receivedBytes)
                      : Formatters.percent(progress.fraction),
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: indeterminate ? null : progress.fraction,
                minHeight: 10,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(
                  icon: Icons.download_rounded,
                  value: progress.totalBytes > 0
                      ? '${Formatters.fileSize(progress.receivedBytes)} / ${Formatters.fileSize(progress.totalBytes)}'
                      : Formatters.fileSize(progress.receivedBytes),
                ),
                _Stat(
                  icon: Icons.speed_rounded,
                  value: Formatters.speed(
                      progress.receivedBytes, progress.elapsed),
                ),
                _Stat(
                  icon: Icons.timer_outlined,
                  value: Formatters.eta(
                    received: progress.receivedBytes,
                    total: progress.totalBytes,
                    elapsed: progress.elapsed,
                  ),
                  label: 'ETA',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Elapsed ${Formatters.duration(progress.elapsed)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, this.label});

  final IconData icon;
  final String value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label == null ? value : '$label $value',
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
