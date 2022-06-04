import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone.dart';

class FlyZoneController {
  final TickerProvider _ticker;

  final isDartDragging = ValueNotifier<bool>(false);
  final ValueNotifier<Offset> dartPosition;
  final dartBuilder = ValueNotifier<FloatingBuilder?>(null);

  late final dartVisibility = AnimationController(
    vsync: _ticker,
    duration: const Duration(milliseconds: 250),
    value: 1.0,
  );

  late final targetVisibility = AnimationController(
    vsync: _ticker,
    duration: const Duration(milliseconds: 500),
  );

  FlyZoneController({
    required TickerProvider vsync,
    Offset initialPosition = const Offset(20.0, 20.0),
  })  : _ticker = vsync,
        dartPosition = ValueNotifier<Offset>(initialPosition) {
    isDartDragging.addListener(_listener);
  }

  void show() async {
    await dartVisibility.forward();
    dartBuilder.value = null;
  }

  void _listener() {
    if (isDartDragging.value) {
      targetVisibility.forward();
    } else {
      targetVisibility.reverse();
    }
  }

  void dispose() {
    isDartDragging.dispose();
    dartPosition.dispose();
    dartPosition.dispose();
    dartVisibility.dispose();
    targetVisibility.dispose();
  }
}
