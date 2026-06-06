import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../providers/converter_controller.dart';
import '../widgets/binding_switcher.dart';
import '../widgets/manuscript/crest.dart';
import '../widgets/manuscript/mss_icons.dart';
import '../widgets/manuscript/ornaments.dart';
import '../widgets/manuscript/primitives.dart';

/// Phase 1 — paste a link and Retrieve.
class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key, required this.binding});
  final ManuscriptBinding binding;

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
    final bool canRetrieve = _url.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 40, 26, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Crest(binding: b),
          const SizedBox(height: 24),
          Fleuron(glyph: b.ornament == 2 ? '❧' : '✦', gold: b.gold),
          const SizedBox(height: 18),
          const BindingSwitcher(),
          const SizedBox(height: 26),
          MssLabel('Paste a Link', gold: b.gold),
          const SizedBox(height: 12),
          MssField(
            controller: _url,
            binding: b,
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
            leading: MssIcon('clipboard', size: 15, color: const Color(0xFFC9B999)),
            onPressed: _paste,
          ),
          const SizedBox(height: 40),
          MssPrimaryButton(
            binding: b,
            label: 'Retrieve',
            trailing: MssIcon('arrow', size: 18, color: Mss.ink),
            onPressed: canRetrieve ? _retrieve : null,
          ),
          const SizedBox(height: 16),
          Text(
            'Of YouTube, Vimeo, and kindred sources.',
            textAlign: TextAlign.center,
            style: Mss.serif(const TextStyle(
                fontSize: 12.5, letterSpacing: 0.2, color: Mss.faint)),
          ),
        ],
      ),
    );
  }
}
