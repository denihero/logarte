import 'package:flutter/material.dart';
import 'package:logarte/logarte.dart';

int _tapCount = 0;

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

  /// Creates a new instance of [LogarteMagicalTap].
  ///
  /// The [child] and [logarte] arguments are required.
  const LogarteMagicalTap({
    Key? key,
    required this.child,
    required this.logarte,
    this.behavior = HitTestBehavior.translucent,
  }) : super(key: key);

  @override
  State<LogarteMagicalTap> createState() => _LogarteMagicalTapState();
}

class _LogarteMagicalTapState extends State<LogarteMagicalTap> {
  static const int _activationTapCount = 10;
  static const int _deactivationTapCount = 20;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: () {
        _tapCount++;
        _handleLogarteVisibility(context);
      },
      child: widget.child,
    );
  }

  void _handleLogarteVisibility(BuildContext context) {
    if (_tapCount == _activationTapCount) {
      widget.logarte.attach(context: context, visible: true);
    } else if (_tapCount == _deactivationTapCount) {
      widget.logarte.attach(context: context, visible: false);
      _tapCount = 0;
    }
  }
}
