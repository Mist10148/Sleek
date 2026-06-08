import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

/// Small helpers for adapting the layout between phones and tablets.
class Responsive {
  Responsive._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

  /// Horizontal page padding — roomier on tablets.
  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: isTablet(context) ? 32 : 16,
        vertical: 16,
      );
}

/// Centers its [child] and caps the width on large screens so content stays
/// comfortably readable on tablets and in landscape.
///
/// Leave [maxWidth] unset to use the responsive default — the manuscript
/// column on phones, widened on tablets so the app doesn't read as a phone
/// window stranded in a sea of empty surround (pass an explicit value only
/// when a screen needs a different cap regardless of device size).
class ContentContainer extends StatelessWidget {
  const ContentContainer({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final double effectiveMax = maxWidth ??
        (Responsive.isTablet(context)
            ? AppConstants.maxContentWidthTablet
            : AppConstants.maxContentWidth);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMax),
        child: child,
      ),
    );
  }
}
