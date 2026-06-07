import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/manuscript_theme.dart';
import '../../../../../core/theme/mss_palette.dart';

/// Small-caps gold label (`.mss-label`).
class MssLabel extends StatelessWidget {
  const MssLabel(this.text, {super.key, required this.gold});
  final String text;
  final Color gold;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: Mss.label(gold));
}

/// Multi-line paste field with a terracotta focus ring (`.mss-field`).
class MssField extends StatefulWidget {
  const MssField({
    super.key,
    required this.controller,
    required this.binding,
    required this.palette,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ManuscriptBinding binding;
  final MssPalette palette;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  @override
  State<MssField> createState() => _MssFieldState();
}

class _MssFieldState extends State<MssField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool focused = _focus.hasFocus;
    final ManuscriptBinding b = widget.binding;
    final MssPalette p = widget.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: p.fieldBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: focused ? b.accent : p.rule(0.26),
        ),
        boxShadow: focused
            ? <BoxShadow>[BoxShadow(color: b.accentSoft, blurRadius: 0, spreadRadius: 3)]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        maxLines: 2,
        minLines: 2,
        cursorColor: b.accent,
        keyboardType: TextInputType.url,
        style: p.mono(TextStyle(
            fontSize: 12.5, letterSpacing: -0.25, color: p.display, height: 1.3)),
        decoration: InputDecoration.collapsed(
          hintText: widget.hintText,
          hintStyle: p.mono(TextStyle(fontSize: 12.5, color: p.hintColor)),
        ),
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSubmitted?.call(),
      ),
    );
  }
}

/// Primary gradient button (`.mss-btn-primary`).
class MssPrimaryButton extends StatelessWidget {
  const MssPrimaryButton({
    super.key,
    required this.binding,
    required this.palette,
    required this.label,
    this.trailing,
    this.leading,
    this.onPressed,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final String label;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final ManuscriptBinding b = binding;
    return _Pressable(
      onPressed: onPressed,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[b.accent, b.accentDeep],
            ),
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                        color: b.accentDeep.withValues(alpha: 0.6),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                        spreadRadius: -10),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (leading != null) ...<Widget>[leading!, const SizedBox(width: 9)],
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.spectral(
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: palette.ink)),
                ),
              ),
              if (trailing != null) ...<Widget>[const SizedBox(width: 9), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Outlined ghost button (`.mss-btn-ghost`).
class MssGhostButton extends StatelessWidget {
  const MssGhostButton({
    super.key,
    required this.label,
    required this.palette,
    this.leading,
    this.onPressed,
    this.dense = false,
  });

  final String label;
  final MssPalette palette;
  final Widget? leading;
  final VoidCallback? onPressed;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final MssPalette p = palette;
    return _Pressable(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 9 : 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: p.rule(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (leading != null) ...<Widget>[leading!, const SizedBox(width: 9)],
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.spectral(
                    textStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: p.ghostLabel)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Press-down micro-interaction shared by the buttons.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, this.onPressed});
  final Widget child;
  final VoidCallback? onPressed;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _down ? 0.992 : 1,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
