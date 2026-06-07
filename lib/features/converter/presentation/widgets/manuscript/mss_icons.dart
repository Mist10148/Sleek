import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The design's stroke icons, ported verbatim from the bundle's `kit.jsx` SVG
/// path data and rendered with `flutter_svg`. Tinting is applied with a srcIn
/// color filter so a single markup string works for any color.
class MssIcon extends StatelessWidget {
  const MssIcon(this.name, {super.key, this.size = 18, required this.color});

  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String inner = _icons[name] ?? '';
    final String svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">$inner</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

// Stroke defaults matching the design: width 1.6, round caps/joins, no fill.
const String _s =
    'fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"';

const Map<String, String> _icons = <String, String>{
  'clipboard': '<path d="M9 4h6v3H9z" $_s/>'
      '<path d="M8 5.5H6a1 1 0 0 0-1 1V20a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V6.5a1 1 0 0 0-1-1h-2" $_s/>',
  'arrow': '<path d="M5 12h13" $_s/><path d="M12 5l7 7-7 7" $_s/>',
  'play': '<path d="M8 5.5v13l11-6.5z" fill="black"/>',
  'pause': '<rect x="6.5" y="5.5" width="3.6" height="13" rx="1" fill="black"/>'
      '<rect x="13.9" y="5.5" width="3.6" height="13" rx="1" fill="black"/>',
  'next': '<path d="M6 6v12l9-6z" fill="black"/>'
      '<rect x="16.5" y="5.5" width="2.6" height="13" rx="1" fill="black"/>',
  'prev': '<path d="M18 6v12l-9-6z" fill="black"/>'
      '<rect x="4.9" y="5.5" width="2.6" height="13" rx="1" fill="black"/>',
  'shuffle': '<path d="M4 7h3.5c1.5 0 2.4.7 3.3 2M20 7h-4M20 7l-2.4-2.2M20 7l-2.4 2.2" $_s/>'
      '<path d="M4 17h3.5c2.6 0 4-2.8 5.6-5.3 1-1.6 2-2.7 3.4-2.7H20M20 17h-4M20 17l-2.4-2.2M20 17l-2.4 2.2" $_s/>',
  'repeat': '<path d="M6 9V8a3 3 0 0 1 3-3h9M18 5l-2.4-2M18 5l-2.4 2" $_s/>'
      '<path d="M18 15v1a3 3 0 0 1-3 3H6M6 19l2.4-2M6 19l2.4 2" $_s/>',
  'repeatOne': '<path d="M6 9V8a3 3 0 0 1 3-3h9M18 5l-2.4-2M18 5l-2.4 2" $_s/>'
      '<path d="M18 15v1a3 3 0 0 1-3 3H6M6 19l2.4-2M6 19l2.4 2" $_s/>'
      '<text x="12" y="14.5" text-anchor="middle" font-family="JetBrains Mono, monospace" font-size="7" font-weight="700" fill="black" stroke="none">1</text>',
  'heart': '<path d="M12 19.5C7 16 4 13 4 9.6 4 7.3 5.8 5.5 8 5.5c1.5 0 2.9.8 4 2.3 1.1-1.5 2.5-2.3 4-2.3 2.2 0 4 1.8 4 4.1 0 3.4-3 6.4-8 9.9z" $_s/>',
  'heartFill': '<path d="M12 19.5C7 16 4 13 4 9.6 4 7.3 5.8 5.5 8 5.5c1.5 0 2.9.8 4 2.3 1.1-1.5 2.5-2.3 4-2.3 2.2 0 4 1.8 4 4.1 0 3.4-3 6.4-8 9.9z" fill="black"/>',
  'queue': '<path d="M4 7h11M4 12h11M4 17h7" $_s/><path d="M17 13v6.5" $_s/>'
      '<circle cx="19.4" cy="19" r="1.8" fill="black" stroke="none"/>'
      '<path d="M17 13l4-1v5" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>',
  'downloadTab': '<path d="M12 3v10M8 10l4 4 4-4M5 20h14" $_s/>',
  'libraryTab': '<path d="M5 4v16M9 4v16" $_s/>'
      '<rect x="12.5" y="4" width="6.5" height="16" rx="1" fill="none" stroke="black" stroke-width="1.6" transform="rotate(8 15.5 12)"/>',
  'settingsTab': '<circle cx="12" cy="12" r="3" fill="none" stroke="black" stroke-width="1.6"/>'
      '<path d="M12 3.5v2.2M12 18.3v2.2M20.5 12h-2.2M5.7 12H3.5M18 6l-1.6 1.6M7.6 16.4 6 18M18 18l-1.6-1.6M7.6 7.6 6 6" $_s/>',
  'history': '<path d="M3.5 12a8.5 8.5 0 1 0 2.6-6.1M3.5 4.5V9h4.5M12 7.5V12l3 2" $_s/>',
  'palette': '<path d="M12 3.5a8.5 8.5 0 0 0 0 17c1.4 0 2-1 2-1.8 0-1.3-1.2-1.5-1.2-2.7 0-.8.7-1.5 1.6-1.5H17a3.5 3.5 0 0 0 3.5-3.5C20.5 6.6 16.7 3.5 12 3.5z" $_s/>'
      '<circle cx="8" cy="11" r="1.1" fill="black" stroke="none"/>'
      '<circle cx="12" cy="8" r="1.1" fill="black" stroke="none"/>'
      '<circle cx="16" cy="10.5" r="1.1" fill="black" stroke="none"/>',
  'trash': '<path d="M5 7h14M10 7V5.5a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1V7M6.5 7l.8 12a1 1 0 0 0 1 .9h7.4a1 1 0 0 0 1-.9l.8-12" $_s/>',
  'chevronR': '<path d="M9 6l6 6-6 6" $_s/>',
  'music': '<path d="M9 18V6l10-2v11" $_s/>'
      '<circle cx="6.5" cy="18" r="2.6" fill="none" stroke="black" stroke-width="1.6"/>'
      '<circle cx="16.5" cy="15" r="2.6" fill="none" stroke="black" stroke-width="1.6"/>',
  'film': '<rect x="3.5" y="5.5" width="17" height="13" rx="1.5" fill="none" stroke="black" stroke-width="1.6"/>'
      '<path d="M9 5.5v13M15 5.5v13M3.5 9.5h17M3.5 14.5h17" $_s/>',
  'folder': '<path d="M4 6.5h5l2 2.2h9V18a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6.5z" $_s/>',
  'chevron': '<path d="M6 9.5l6 6 6-6" $_s/>',
  'check': '<path d="M5 12.5l4.5 4.5L19 7" $_s/>',
  'x': '<path d="M6 6l12 12M18 6L6 18" $_s/>',
  'download': '<path d="M12 4v11M7 11l5 5 5-5M5 20h14" $_s/>',
  'quill': '<path d="M4 20c6-1 8-3 11-6 2.4-2.4 3.5-5.2 4-9-3.8.5-6.6 1.6-9 4-3 3-5 5-6 11z" $_s/>'
      '<path d="M8.5 15.5l3-3" $_s/>',
  'eye': '<path d="M2 12s3.5-6.5 10-6.5S22 12 22 12s-3.5 6.5-10 6.5S2 12 2 12z" $_s/>'
      '<circle cx="12" cy="12" r="2.4" fill="none" stroke="black" stroke-width="1.6"/>',
  'clock': '<circle cx="12" cy="12" r="8.2" fill="none" stroke="black" stroke-width="1.6"/>'
      '<path d="M12 8v4.2l2.8 1.8" $_s/>',
  'open': '<path d="M14 5h5v5M19 5l-7 7M11 5H6a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-5" $_s/>',
  'moon': '<path d="M20 14.5A8.5 8.5 0 0 1 9.5 4 8.5 8.5 0 1 0 20 14.5z" $_s/>',
  'sun': '<circle cx="12" cy="12" r="4.2" $_s/>'
      '<path d="M12 2.5v2.4M12 19.1v2.4M4.6 4.6l1.7 1.7M17.7 17.7l1.7 1.7M2.5 12h2.4M19.1 12h2.4M4.6 19.4l1.7-1.7M17.7 6.3l1.7-1.7" $_s/>',
  'gear': '<circle cx="12" cy="12" r="3" $_s/>'
      '<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" $_s/>',
};
