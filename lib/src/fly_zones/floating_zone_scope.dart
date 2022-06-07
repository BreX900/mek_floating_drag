import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zones/floating_zone_controller.dart';

class FloatingZoneScope extends InheritedWidget {
  final FloatingZoneController controller;
  final RenderBox Function() _renderBoxGetter;

  RenderBox get renderBox => _renderBoxGetter();

  const FloatingZoneScope({
    Key? key,
    required this.controller,
    required RenderBox Function() renderBoxGetter,
    required Widget child,
  })  : _renderBoxGetter = renderBoxGetter,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(FloatingZoneScope oldWidget) =>
      controller != oldWidget.controller || _renderBoxGetter != oldWidget._renderBoxGetter;
}
