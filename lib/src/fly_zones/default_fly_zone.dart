import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zones/fly_zone.dart';
import 'package:mek_floating_drag/src/fly_zones/fly_zone_controller.dart';

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
