import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logarte/logarte.dart';

class LogarteOverlay extends StatelessWidget {
  final Logarte instance;
  static OverlayEntry? _entry;

  const LogarteOverlay._internal({
    required this.instance,
    Key? key,
  }) : super(key: key);

  static void attach({
    required BuildContext context,
    required Logarte instance,
  }) {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (context) {
        return LogarteOverlay._internal(
          instance: instance,
        );
      },
    );

    Future.delayed(kThemeAnimationDuration, () {
      final overlay = Overlay.of(context);

      if (_entry != null) {
        overlay.insert(_entry!);
      }
    });
  }

  static void detach() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.height / 2) - 12.0;

    return Positioned(
      right: 0.0,
      bottom: height,
      child: _LogarteFAB(
        instance: instance,
      ),
    );
  }
}

class _LogarteFAB extends StatefulWidget {
  final Logarte instance;

  const _LogarteFAB({
    Key? key,
    required this.instance,
  }) : super(key: key);

  @override
  _LogarteFABState createState() => _LogarteFABState();
}

class _LogarteFABState extends State<_LogarteFAB> {
  ValueNotifier<bool> isOpened = ValueNotifier(false);

  Future<void> _onPressed(BuildContext context) async {
    if (isOpened.value) {
      Navigator.of(context).popUntil((route) => route.settings.name == '/logarte_auth');
      if(Navigator.canPop(context)){
        Navigator.pop(context);
      }
    } else {
      Navigator.of(context).pushNamed<void>(
        '/logarte_auth',
        arguments: widget.instance,
      );
    }

    isOpened.value = !isOpened.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onPressed(context),
      onDoubleTap: () {
        if (!isOpened.value) {
          widget.instance.onRocketDoubleTapped?.call(context);
        }
      },
      onLongPress: () {
        if (!isOpened.value) {
          widget.instance.onRocketLongPressed?.call(context);
        }
      },
      child: Container(
        width: 52.0,
        height: 52.0,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: isOpened,
          builder: (context, bool value, _) {
            return Icon(
              value ? Icons.close : Icons.rocket_launch_rounded,
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }
}
