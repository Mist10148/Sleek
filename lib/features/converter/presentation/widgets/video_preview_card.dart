import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/models/video_info.dart';

/// Thumbnail + title + author + duration for the fetched video.
class VideoPreviewCard extends StatelessWidget {
  const VideoPreviewCard({super.key, required this.info});

  final VideoInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  info.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.ondemand_video_rounded, size: 48),
                  ),
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                ),
                if (info.duration != null)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        Formatters.duration(info.duration!),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        info.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
