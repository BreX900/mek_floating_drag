import 'package:flutter/material.dart';
import 'package:mek_floating_drag/src/floating_drag_bin/floating_drag_bin.dart';
import 'package:mek_floating_drag/src/floating_drag_bin/floating_drag_target_controller.dart';

class FloatingCircularDragBin extends StatelessWidget {
  final FloatingDragTargetController? controller;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final Widget icon;

  const FloatingCircularDragBin({
    Key? key,
    this.controller,
    this.size = 100,
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.red,
    this.icon = const Icon(Icons.close),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingDragBin(
      controller: controller,
      builder: (context) {
        return SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: foregroundColor,
              ),
              child: icon,
            ),
          ),
        );
      },
    );
  }
}
