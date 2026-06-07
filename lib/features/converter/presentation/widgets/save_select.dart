import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/manuscript_theme.dart';
import '../../../../core/theme/mss_palette.dart';
import 'manuscript/mss_icons.dart';

/// A save destination: a friendly [name] and its filesystem [path].
class SaveLocation {
  const SaveLocation({required this.name, required this.path});
  final String name;
  final String path;
}

/// Custom "Save To" dropdown. The menu is a true floating overlay anchored to
/// the button via [OverlayPortal] + [CompositedTransformFollower].
class SaveSelect extends StatefulWidget {
  const SaveSelect({
    super.key,
    required this.binding,
    required this.palette,
    required this.current,
    required this.presets,
    required this.onSelect,
    required this.onBrowse,
  });

  final ManuscriptBinding binding;
  final MssPalette palette;
  final SaveLocation current;
  final List<SaveLocation> presets;
  final ValueChanged<SaveLocation> onSelect;
  final VoidCallback onBrowse;

  @override
  State<SaveSelect> createState() => _SaveSelectState();
}

class _SaveSelectState extends State<SaveSelect> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  double _width = 0;
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    _portal.toggle();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    final ManuscriptBinding b = widget.binding;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        _width = c.maxWidth;
        return CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: _buildOverlay,
            child: _button(b),
          ),
        );
      },
    );
  }

  Widget _button(ManuscriptBinding b) {
    final MssPalette p = widget.palette;
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: p.overlay50,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: _open ? b.accent : p.rule(0.26)),
          boxShadow: _open
              ? <BoxShadow>[
                  BoxShadow(color: b.accentSoft, spreadRadius: 3, blurRadius: 0)
                ]
              : null,
        ),
        child: Row(
          children: <Widget>[
            MssIcon('folder', size: 17, color: b.accent),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.current.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: p.serif(TextStyle(
                          fontSize: 14.5, color: p.display))),
                  const SizedBox(height: 2),
                  Text(widget.current.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: p.mono(
                          TextStyle(fontSize: 10.5, color: p.faint))),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: MssIcon('chevron', size: 15, color: p.faint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final ManuscriptBinding b = widget.binding;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 6),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _width,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                builder: (BuildContext context, double t, Widget? child) =>
                    Opacity(
                  opacity: t,
                  child: Transform.translate(
                      offset: Offset(0, (1 - t) * -5), child: child),
                ),
                child: _menu(b),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menu(ManuscriptBinding b) {
    final MssPalette p = widget.palette;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: p.menuBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: p.rule(0.3)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 48,
                offset: const Offset(0, 22),
                spreadRadius: -18),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final SaveLocation l in widget.presets)
              _row(
                b, p,
                label: l.name,
                selected: l.path == widget.current.path,
                onTap: () {
                  widget.onSelect(l);
                  _close();
                },
              ),
            _row(
              b, p,
              label: 'Browse for a folder…',
              sep: true,
              trailing: Text('›', style: TextStyle(fontSize: 15, color: b.accent)),
              onTap: () {
                widget.onBrowse();
                _close();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    ManuscriptBinding b,
    MssPalette p, {
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    bool sep = false,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: b.accentSoft,
      child: Container(
        decoration: sep
            ? BoxDecoration(
                border: Border(top: BorderSide(color: p.rule(0.18))))
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            MssIcon('folder',
                size: 16, color: sep ? b.accent : p.menuItem),
            const SizedBox(width: 11),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ebGaramond(
                      textStyle: TextStyle(
                          fontSize: 14,
                          color: sep ? b.accent : p.menuItem))),
            ),
            if (selected) MssIcon('check', size: 16, color: b.accent),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
