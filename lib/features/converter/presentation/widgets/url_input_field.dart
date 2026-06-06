import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/validators.dart';

/// Paste-a-link field with inline validation and a "fetch" action.
class UrlInputField extends StatefulWidget {
  const UrlInputField({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    this.initialValue = '',
  });

  final ValueChanged<String> onSubmit;
  final bool isLoading;
  final String initialValue;

  @override
  State<UrlInputField> createState() => _UrlInputFieldState();
}

class _UrlInputFieldState extends State<UrlInputField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    final error = Validators.youtubeUrlError(text);
    setState(() => _error = error);
    if (error == null) {
      FocusScope.of(context).unfocus();
      widget.onSubmit(text);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!.trim();
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'Paste YouTube link…',
            prefixIcon: const Icon(Icons.link_rounded),
            errorText: _error,
            suffixIcon: IconButton(
              tooltip: 'Paste',
              icon: const Icon(Icons.content_paste_rounded),
              onPressed: widget.isLoading ? null : _paste,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: widget.isLoading ? null : _submit,
          icon: widget.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search_rounded),
          label: Text(widget.isLoading ? 'Fetching…' : 'Fetch video'),
        ),
      ],
    );
  }
}
