import 'package:flutter/material.dart';
import 'package:mek_floating_drag/src/targets/floating_target.dart';
import 'package:mek_floating_drag/src/targets/floating_target_controller.dart';

class FloatingBallTarget extends StatelessWidget {
  final FloatingTargetController? controller;

  const FloatingBallTarget({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingTarget(
      controller: controller,
      builder: (context) {
        return const SizedBox(
          width: 100.0,
          height: 100.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: Icon(Icons.close),
          ),
        );
      },
    );
  }
}
