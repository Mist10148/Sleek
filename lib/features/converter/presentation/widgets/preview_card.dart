import 'package:flutter/material.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/video_info.dart';
import 'manuscript/mss_icons.dart';
import 'manuscript/ornaments.dart';

/// The video "Record" card: a sepia-treated real thumbnail with a play glyph and
/// duration badge, then title + channel/views/duration. Gains gilt borders +
/// corner flourishes (illuminated) and a "REF" ink stamp (folio). Ported from
/// the preview card in the design's `Downloader.jsx`.
class PreviewCard extends StatelessWidget {
  const PreviewCard({super.key, required this.binding, required this.info});

  final ManuscriptBinding binding;
  final VideoInfo info;

  // Warm sepia color matrix applied over the real thumbnail.
  static const List<double> _sepia = <double>[
    0.393, 0.769, 0.189, 0, -18, //
    0.349, 0.686, 0.168, 0, -12, //
    0.272, 0.534, 0.131, 0, -8, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final bool gilt = binding.ornament == 2;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x99140F0A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: gilt ? const Color(0x80CBA86A) : Mss.rule(0.24)),
        boxShadow: gilt
            ? <BoxShadow>[
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                    spreadRadius: -24),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _thumb(gilt),
          Padding(
            padding: EdgeInsets.fromLTRB(gilt ? 18 : 16, gilt ? 16 : 15,
                gilt ? 18 : 16, gilt ? 18 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _title(),
                const SizedBox(height: 9),
                _meta(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(bool gilt) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Warm manuscript base (shows through while the image loads / fails).
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.44, -0.6),
                radius: 1.3,
                colors: <Color>[Color(0xFF5A3F2C), Color(0xFF3A2A1E), Color(0xFF241A12)],
                stops: <double>[0.0, 0.55, 1.0],
              ),
            ),
          ),
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(_sepia),
            child: Image.network(
              info.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  const SizedBox.shrink(),
            ),
          ),
          // Warm multiply wash to seat the image in the palette.
          DecoratedBox(
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.multiply,
              color: const Color(0xFF3A2A1E).withValues(alpha: 0.45),
            ),
          ),
          if (gilt) ...<Widget>[
            CornerFlourish(pos: 'tl', color: binding.gold),
            CornerFlourish(pos: 'tr', color: binding.gold),
          ],
          if (binding.catalog) _refStamp(),
          Center(child: _play()),
          Positioned(right: 9, bottom: 9, child: _badge()),
        ],
      ),
    );
  }

  Widget _play() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x8C140D08),
        border: Border.all(color: const Color(0xB3F1E7D4), width: 1.5),
      ),
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.only(left: 3),
        child: MssIcon('play', size: 18, color: Mss.display),
      ),
    );
  }

  Widget _badge() {
    final String d = info.duration != null ? Formatters.duration(info.duration!) : '';
    if (d.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xD108_0503),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(d,
          style: Mss.mono(const TextStyle(fontSize: 10.5, color: Color(0xFFEDE0C8)))),
    );
  }

  Widget _refStamp() {
    return Positioned(
      top: 10,
      left: 10,
      child: Transform.rotate(
        angle: -7 * 3.1415926 / 180,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0x8CF1E7D4), width: 1.5),
          ),
          child: Text('REF · ML-410.7',
              style: Mss.mono(const TextStyle(
                  fontSize: 8.5, letterSpacing: 1, color: Color(0xBFF1E7D4)))),
        ),
      ),
    );
  }

  Widget _title() {
    final TextStyle base = binding.display0(const TextStyle(
        fontSize: 17.5, height: 1.32, fontWeight: FontWeight.w500, color: Mss.display));
    if (binding.dropcap) {
      return _DropCapText(text: info.title, style: base, accent: binding.accent,
          displayFont: binding);
    }
    return Text(info.title, style: base);
  }

  Widget _meta() {
    final TextStyle s =
        Mss.serif(const TextStyle(fontSize: 13, color: Mss.muted));
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(info.author,
            style: Mss.serif(TextStyle(fontSize: 13, color: binding.gold))),
        Text('·', style: const TextStyle(color: Mss.faint)),
        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          MssIcon('eye', size: 12, color: Mss.muted),
          const SizedBox(width: 4),
          Text('Watch', style: s),
        ]),
        if (info.duration != null) ...<Widget>[
          Text('·', style: const TextStyle(color: Mss.faint)),
          Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            MssIcon('clock', size: 12, color: Mss.muted),
            const SizedBox(width: 4),
            Text(Formatters.duration(info.duration!), style: s),
          ]),
        ],
      ],
    );
  }
}

/// Title with an illuminated drop-cap first letter.
class _DropCapText extends StatelessWidget {
  const _DropCapText({
    required this.text,
    required this.style,
    required this.accent,
    required this.displayFont,
  });

  final String text;
  final TextStyle style;
  final Color accent;
  final ManuscriptBinding displayFont;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return Text(text, style: style);
    final String first = text.substring(0, 1);
    final String rest = text.substring(1);
    return Text.rich(
      TextSpan(children: <InlineSpan>[
        TextSpan(
          text: first,
          style: displayFont.display0(TextStyle(
              fontSize: 46,
              height: 0.84,
              fontWeight: FontWeight.w500,
              color: accent)),
        ),
        TextSpan(text: rest, style: style),
      ]),
    );
  }
}
