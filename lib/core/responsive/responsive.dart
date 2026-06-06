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
class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.maxWidth = AppConstants.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
