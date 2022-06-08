import 'package:flutter/widgets.dart';

class FloatingDragTargetController {
  final TickerProvider _vsync;

  final Duration _visibilityDuration;
  final Curve _visibilityCurve;

  late final _visibilityController = AnimationController(vsync: _vsync);
  Animation<double> get visibilityAnimation => _visibilityController.view;

  FloatingDragTargetController({
    required TickerProvider vsync,
    Duration visibilityDuration = const Duration(milliseconds: 300),
    Curve visibilityCurve = Curves.easeInToLinear,
  })  : _vsync = vsync,
        _visibilityDuration = visibilityDuration,
        _visibilityCurve = visibilityCurve;

  Future<void> show() async {
    await _visibilityController.animateTo(
      1.0,
      duration: _visibilityDuration,
      curve: _visibilityCurve,
    );
  }

  Future<void> hide() async {
    await _visibilityController.animateTo(
      0.0,
      duration: _visibilityDuration,
      curve: _visibilityCurve,
    );
  }

  void dispose() {
    _visibilityController.dispose();
  }
}
