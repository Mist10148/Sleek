import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/services/history_service.dart';
import '../../domain/entities/media_format.dart';
import 'manuscript/mss_icons.dart';
import 'manuscript/primitives.dart';

/// "Recently Transcribed" — a horizontal shelf of small receipts for the last
/// few finished jobs, shown on the input screen once any exist. Echoes the
/// visual language of `ReceiptCard` / `PreviewCard` (binding-aware palette,
/// hairline borders, warm thumbnail treatment) at a size that fits a row.
/// Tapping a card reopens its file directly — the same `open_filex` hop
/// `DoneScreen`'s "Reveal in folder" already uses.
class HistoryRail extends StatelessWidget {
  const HistoryRail({
    super.key,
    required this.binding,
    required this.palette,
    required this.entries,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final List<HistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = binding;
    final MssPalette p = palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MssLabel('Recently Transcribed', gold: b.gold),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: entries.length,
            separatorBuilder: (BuildContext context, int i) =>
                const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int i) =>
                _HistoryCard(binding: b, palette: p, entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.binding,
    required this.palette,
    required this.entry,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = binding;
    final MssPalette p = palette;
    return SizedBox(
      width: 140,
      child: Container(
        decoration: BoxDecoration(
          color: p.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: p.rule(0.24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: entry.filePath.isEmpty
                ? null
                : () => OpenFilex.open(entry.filePath),
            hoverColor: b.accentSoft,
            splashColor: b.accentSoft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _thumb(p),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: p.serif(TextStyle(
                            fontSize: 12,
                            height: 1.28,
                            fontWeight: FontWeight.w500,
                            color: p.display)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${entry.qualityLabel} · ${Formatters.timeAgo(entry.completedAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: p.mono(TextStyle(fontSize: 9.5, color: p.faint)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A small sepia-toned still — the same warm gradient ground `PreviewCard`
  /// rests its thumbnails on, just without the live "about to play" chrome,
  /// since this one's already been read. A corner glyph names its format.
  Widget _thumb(MssPalette p) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.4, -0.6),
                radius: 1.3,
                colors: <Color>[
                  Color(0xFF5A3F2C),
                  Color(0xFF3A2A1E),
                  Color(0xFF241A12),
                ],
              ),
            ),
          ),
          if (entry.thumbnailUrl.isNotEmpty)
            Image.network(
              entry.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  const SizedBox.shrink(),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.multiply,
              color: Color(0x733A2A1E),
            ),
          ),
          Positioned(
            right: 7,
            bottom: 7,
            child: Container(
              width: 23,
              height: 23,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xD1080503),
                border: Border.fromBorderSide(
                    BorderSide(color: Color(0x59F1E7D4))),
              ),
              alignment: Alignment.center,
              child: MssIcon(entry.format == MediaFormat.mp3 ? 'music' : 'film',
                  size: 11, color: const Color(0xFFEDE0C8)),
            ),
          ),
        ],
      ),
    );
  }
}
