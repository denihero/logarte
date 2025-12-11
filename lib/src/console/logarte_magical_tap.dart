import 'package:flutter/material.dart';
import 'package:logarte/logarte.dart';

int tapCount = 0;

/// A widget that detects taps and shows the [Logarte] widget when the user
class LogarteMagicalTap extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// How this gesture detector should behave during hit testing.
  ///
  /// Defaults to [HitTestBehavior.translucent].
  final HitTestBehavior behavior;

  /// The [Logarte] instance to show when the user taps the widget.
  final Logarte logarte;

  final bool isEnabled;

  /// Creates a new instance of [LogarteMagicalTap].
  ///
  /// The [child] and [logarte] arguments are required.
  const LogarteMagicalTap({
    super.key,
    required this.child,
    required this.logarte,
    this.isEnabled = false,
    this.behavior = HitTestBehavior.translucent,
  });

  @override
  State<LogarteMagicalTap> createState() => _LogarteMagicalTapState();
}

class _LogarteMagicalTapState extends State<LogarteMagicalTap> {
  static const int _activationTapCount = 10;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: () {
        if (!widget.isEnabled) return;

        tapCount++;
        _handleLogarteVisibility(context);
      },
      child: widget.child,
    );
  }

  void _handleLogarteVisibility(BuildContext context) {
    if (tapCount == _activationTapCount) {
      widget.logarte.attach(context: context, visible: true);
    }
  }
}
