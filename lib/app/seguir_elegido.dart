import 'dart:async';

import 'package:flutter/widgets.dart';

/// Wraps a list row: when it becomes the chosen one (↑/↓), the list scrolls
/// so it stays on screen.
class SeguirElegido extends StatefulWidget {
  const SeguirElegido({super.key, required this.elegido, required this.child});

  final bool elegido;
  final Widget child;

  @override
  State<SeguirElegido> createState() => _SeguirElegidoState();
}

class _SeguirElegidoState extends State<SeguirElegido> {
  @override
  void didUpdateWidget(SeguirElegido oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.elegido || oldWidget.elegido) return;
    // After this frame, when the row has its final place in the list.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        ),
      );
      unawaited(
        Scrollable.ensureVisible(
          context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
