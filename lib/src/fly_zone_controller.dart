import 'package:flutter/widgets.dart';

class FlyZoneController extends ChangeNotifier {
  final _dartControllers = <DartController>[];
  final _targetControllers = <TargetController>[];

  void attachDart(DartController controller) {
    _dartControllers.add(controller);
    controller.isDragging.addListener(_listenDartVisibility);
    notifyListeners();
  }

  void detachDart(DartController controller) {
    controller.isDragging.removeListener(_listenDartVisibility);
    _dartControllers.remove(controller);
    notifyListeners();
  }

  void attachTarget(TargetController controller) {
    _targetControllers.add(controller);
    notifyListeners();
  }

  void detachTarget(TargetController controller) {
    _targetControllers.remove(controller);
    notifyListeners();
  }

  void attachScroll(ScrollController controller) {
    controller.addListener(_listenScrollController);
  }

  void _listenDartVisibility() {
    final isDragging = _dartControllers.any((e) => e.isDragging.value);
    for (final controller in _targetControllers) {
      if (isDragging) {
        controller.show();
      } else {
        controller.hide();
      }
    }
  }

  void _listenScrollController() {
    for (final controller in _dartControllers) {
      controller.animateRestrict();
    }
  }
}

class DartController {
  final TickerProvider _vsync;

  final isDragging = ValueNotifier(false);
  final position = ValueNotifier(Offset.zero);

  final Duration _visibilityDuration;

  late final _visibilityController = AnimationController(vsync: _vsync, value: 1.0);
  Animation<double> get visibilityAnimation => _visibilityController.view;

  final Duration _naturalElasticDuration;
  final Curve _naturalElasticCurve;

  late final _naturalElasticController = AnimationController(vsync: _vsync);
  Animation<double> get naturalElasticAnimation => _naturalElasticController.view;

  final Duration _restrictDuration;
  final Curve _restrictCurve;

  late final _restrictController = AnimationController(vsync: _vsync);
  Animation<double> get restrictAnimation => _restrictController.view;

  DartController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 250),
    Duration? visibilityDuration,
    Duration? naturalElasticDuration,
    Curve naturalElasticCurve = Curves.bounceInOut,
    Duration? restrictDuration,
    Curve restrictCurve = Curves.linearToEaseOut,
  })  : _vsync = vsync,
        _visibilityDuration = visibilityDuration ?? duration,
        _naturalElasticDuration = naturalElasticDuration ?? duration,
        _naturalElasticCurve = naturalElasticCurve,
        _restrictDuration = restrictDuration ?? duration,
        _restrictCurve = restrictCurve;

  Future<void> show() async {
    await _visibilityController.animateTo(1.0, duration: _visibilityDuration);
  }

  Future<void> hide() async {
    await _visibilityController.animateTo(0.0, duration: _visibilityDuration);
  }

  Future<void> animateElastic() async {
    _naturalElasticController.reset();
    _naturalElasticController.animateTo(
      1.0,
      duration: _naturalElasticDuration,
      curve: _naturalElasticCurve,
    );
  }

  Future<void> animateRestrict() async {
    _restrictController.reset();
    _restrictController.animateTo(
      1.0,
      duration: _restrictDuration,
      curve: _restrictCurve,
    );
  }

  void dragStart() {
    isDragging.value = true;
    _naturalElasticController.stop();
    _restrictController.stop();
  }

  void dragUpdate(Offset delta) {
    position.value += delta;
  }

  void dragEnd() {
    isDragging.value = false;
  }

  void updatePosition(Offset value) {
    position.value = value;
  }

  void dispose() {
    _naturalElasticController.dispose();
    _restrictController.dispose();
  }
}

class TargetController {
  final TickerProvider _vsync;

  final Duration _visibilityDuration;
  final Curve _visibilityCurve;

  late final _visibilityController = AnimationController(vsync: _vsync);
  Animation<double> get visibilityAnimation => _visibilityController.view;

  TargetController({
    required TickerProvider vsync,
    Duration visibilityDuration = const Duration(milliseconds: 250),
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
}
