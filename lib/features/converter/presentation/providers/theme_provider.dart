import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/manuscript_theme.dart';

/// The currently selected binding (I · Codex / II · Folio / III · Illuminated).
/// Defaults to the richest "Illuminated" direction; the switcher calls [select].
class BindingController extends Notifier<ManuscriptBinding> {
  @override
  ManuscriptBinding build() => kIlluminated;

  void select(ManuscriptBinding binding) => state = binding;
}

final bindingProvider =
    NotifierProvider<BindingController, ManuscriptBinding>(BindingController.new);
