import 'package:flutter/material.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../domain/entities/media_format.dart';
import 'manuscript/mss_icons.dart';
import 'manuscript/ornaments.dart';

/// The pop-in success seal (`.mss-done-seal`) — a filled accent disc with a
/// check that springs in with an elastic scale.
class DoneSeal extends StatefulWidget {
  const DoneSeal({super.key, required this.binding});
  final ManuscriptBinding binding;

  @override
  State<DoneSeal> createState() => _DoneSealState();
}

class _DoneSealState extends State<DoneSeal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = widget.binding;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: b.accentDeep, width: 1.5),
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            colors: <Color>[b.accent, b.accentDeep],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(color: b.accentSoft, blurRadius: 22),
          ],
        ),
        alignment: Alignment.center,
        child: const MssIcon('check', size: 30, color: Mss.ink),
      ),
    );
  }
}

/// The file receipt card shown on the Done screen.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    required this.binding,
    required this.fileName,
    required this.format,
    required this.qualityLabel,
    required this.sizeLabel,
    required this.savedPath,
  });

  final ManuscriptBinding binding;
  final String fileName;
  final MediaFormat format;
  final String qualityLabel;
  final String sizeLabel;
  final String savedPath;

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = binding;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0x99140F0A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Mss.rule(0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: b.accentSoft,
                  border: Border.all(color: Mss.rule(0.3)),
                ),
                alignment: Alignment.center,
                child: MssIcon(format == MediaFormat.mp3 ? 'music' : 'film',
                    size: 19, color: b.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Mss.mono(
                            const TextStyle(fontSize: 12.5, color: Mss.display))),
                    const SizedBox(height: 3),
                    Text('${format.label} · $qualityLabel · $sizeLabel',
                        style: Mss.serif(
                            const TextStyle(fontSize: 12, color: Mss.faint))),
                  ],
                ),
              ),
            ],
          ),
          const HairRule(margin: EdgeInsets.symmetric(vertical: 14)),
          Row(
            children: <Widget>[
              MssIcon('folder', size: 15, color: b.gold),
              const SizedBox(width: 8),
              Text('Saved to',
                  style: Mss.serif(const TextStyle(fontSize: 12.5, color: Mss.muted))),
              const SizedBox(width: 8),
              Expanded(
                child: Text(savedPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Mss.mono(
                        const TextStyle(fontSize: 11.5, color: Color(0xFFD7C8AC)))),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
