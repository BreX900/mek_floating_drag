import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone_controller.dart';

typedef FloatingBuilder = Widget Function(BuildContext context, Widget child);

class FlyZone extends InheritedWidget {
  final FlyZoneController controller;

  const FlyZone({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  static FlyZoneController of(BuildContext context, {bool listen = true}) {
    FlyZone flyZone;
    if (listen) {
      flyZone = context.dependOnInheritedWidgetOfExactType<FlyZone>()!;
    } else {
      flyZone = context.findAncestorWidgetOfExactType<FlyZone>()!;
    }
    return flyZone.controller;
  }

  @override
  bool updateShouldNotify(FlyZone oldWidget) => controller != oldWidget.controller;
}

class DefaultFlyZone extends StatefulWidget {
  final Offset initialPosition;
  final Widget child;

  const DefaultFlyZone({
    Key? key,
    this.initialPosition = const Offset(20.0, 20.0),
    required this.child,
  }) : super(key: key);

  @override
  State<DefaultFlyZone> createState() => _DefaultFlyZoneState();
}

class _DefaultFlyZoneState extends State<DefaultFlyZone> with TickerProviderStateMixin {
  late FlyZoneController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlyZoneController(vsync: this);
  }

  @override
  void didUpdateWidget(DefaultFlyZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != oldWidget.initialPosition) {
      _controller.dispose();
      _controller = FlyZoneController(
        initialPosition: widget.initialPosition,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyZone(
      controller: _controller,
      child: widget.child,
    );
  }
}