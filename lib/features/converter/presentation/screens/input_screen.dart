import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import '../../data/services/history_service.dart';
import '../providers/converter_controller.dart';
import '../widgets/history_rail.dart';
import '../widgets/manuscript/crest.dart';
import '../widgets/manuscript/mss_icons.dart';
import '../widgets/manuscript/ornaments.dart';
import '../widgets/manuscript/primitives.dart';

/// Phase 1 — paste a link and Retrieve.
class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key, required this.binding, required this.palette});
  final ManuscriptBinding binding;
  final MssPalette palette;

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  late final TextEditingController _url =
      TextEditingController(text: ref.read(converterControllerProvider).url);

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _retrieve() {
    final String text = _url.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(converterControllerProvider.notifier).loadInfo(text);
  }

  Future<void> _paste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _url.text = text;
      ref.read(converterControllerProvider.notifier).setUrl(text);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = widget.binding;
    final MssPalette p = widget.palette;
    final bool canRetrieve = _url.text.trim().isNotEmpty;
    final List<HistoryEntry> history = ref.watch(historyProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 40, 26, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Crest(binding: b, palette: p),
          const SizedBox(height: 24),
          Fleuron(glyph: b.ornament == 2 ? '❧' : '✦', gold: b.gold),
          // Binding/theme switching now lives exclusively in Settings — this
          // screen only ever *renders* the active binding's look. One
          // balanced gap stands in for the two that used to flank the
          // switcher, keeping the rhythm between the ornament and the label.
          const SizedBox(height: 32),
          MssLabel('Paste a Link', gold: b.gold),
          const SizedBox(height: 12),
          MssField(
            controller: _url,
            binding: b,
            palette: p,
            hintText: 'https://youtube.com/watch?v=…',
            onChanged: (String v) {
              ref.read(converterControllerProvider.notifier).setUrl(v);
              setState(() {});
            },
            onSubmitted: _retrieve,
          ),
          const SizedBox(height: 10),
          MssGhostButton(
            label: 'Paste from clipboard',
            palette: p,
            leading: MssIcon('clipboard', size: 15, color: p.ghostLabel),
            onPressed: _paste,
          ),
          const SizedBox(height: 40),
          MssPrimaryButton(
            binding: b,
            palette: p,
            label: 'Retrieve',
            trailing: MssIcon('arrow', size: 18, color: p.ink),
            onPressed: canRetrieve ? _retrieve : null,
          ),
          const SizedBox(height: 16),
          Text(
            'Of YouTube, Vimeo, and kindred sources.',
            textAlign: TextAlign.center,
            style: p.serif(TextStyle(
                fontSize: 12.5, letterSpacing: 0.2, color: p.faint)),
          ),
          // A shelf of what's already been read — appears only once there's
          // something to show, so a first-run page stays exactly as spare
          // and inviting as it always was.
          if (history.isNotEmpty) ...<Widget>[
            const SizedBox(height: 38),
            HairRule(palette: p, margin: const EdgeInsets.symmetric(horizontal: 6)),
            const SizedBox(height: 28),
            HistoryRail(binding: b, palette: p, entries: history),
          ],
        ],
      ),
    );
  }
}
