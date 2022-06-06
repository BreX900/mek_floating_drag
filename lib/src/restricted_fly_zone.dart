import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/mek_floating_drag.dart';

class RestrictedFlyZone extends StatelessWidget {
  final Widget child;

  const RestrictedFlyZone({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flyZoneController = FlyZone.of(context);

    if (flyZoneController == null) return child;

    return Listener(
      onPointerDown: (_) {
        for (final controller in flyZoneController.dartControllers) {
          controller.animateRestrict();
        }
      },
      child: child,
    );
  }
}
