import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/mek_floating_drag.dart';

class RestrictedFloatingZone extends StatelessWidget {
  final Widget child;

  const RestrictedFloatingZone({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flyZoneController = FloatingZone.of(context)?.controller;

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
