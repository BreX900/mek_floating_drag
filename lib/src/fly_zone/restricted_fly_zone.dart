import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone/fly_zone.dart';

class RestrictedFlyZone extends StatelessWidget {
  final Widget child;

  const RestrictedFlyZone({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flyZoneController = FlyZone.of(context)?.controller;

    if (flyZoneController == null) return child;

    return Listener(
      onPointerDown: (_) {
        for (final controller in flyZoneController.draggableControllers) {
          controller.animateRestrict();
        }
      },
      child: child,
    );
  }
}
