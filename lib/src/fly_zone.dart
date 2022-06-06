import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone_controller.dart';

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
  final Widget child;

  const DefaultFlyZone({
    Key? key,
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
    _controller = FlyZoneController();
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
