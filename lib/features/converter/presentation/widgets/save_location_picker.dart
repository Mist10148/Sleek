import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Shows the current save directory and lets the user pick another via the
/// system directory picker.
class SaveLocationPicker extends StatelessWidget {
  const SaveLocationPicker({
    super.key,
    required this.directory,
    required this.onChanged,
  });

  final String? directory;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final String? path = await FilePicker.getDirectoryPath(
      dialogTitle: 'Choose where to save',
    );
    if (path != null) onChanged(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.folder_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Save to',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(
                    directory ?? 'Default app folder',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
