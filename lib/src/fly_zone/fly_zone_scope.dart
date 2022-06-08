import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone/fly_zone_controller.dart';

class FlyZoneScope extends InheritedWidget {
  final FlyZoneController controller;
  final RenderBox Function() _renderBoxGetter;

  RenderBox get renderBox => _renderBoxGetter();

  const FlyZoneScope({
    Key? key,
    required this.controller,
    required RenderBox Function() renderBoxGetter,
    required Widget child,
  })  : _renderBoxGetter = renderBoxGetter,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(FlyZoneScope oldWidget) =>
      controller != oldWidget.controller || _renderBoxGetter != oldWidget._renderBoxGetter;
}
