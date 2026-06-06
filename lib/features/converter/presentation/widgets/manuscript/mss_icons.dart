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
};
