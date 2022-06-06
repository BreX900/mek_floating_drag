import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zones/fly_zone_controller.dart';

class FlyZone extends InheritedWidget {
  final FlyZoneController controller;

  const FlyZone({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  static FlyZoneController? of(BuildContext context, {bool listen = true}) {
    return context.dependOnInheritedWidgetOfExactType<FlyZone>()?.controller;
  }

  @override
  bool updateShouldNotify(FlyZone oldWidget) => controller != oldWidget.controller;
}
