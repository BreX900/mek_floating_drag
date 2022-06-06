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

  final visibilityDuration = const Duration(milliseconds: 400);

  final naturalElasticDuration = const Duration(milliseconds: 400);
  final naturalElasticCurve = Curves.bounceOut;

  final restrictDuration = const Duration(milliseconds: 400);

  late final _visibilityController = AnimationController(vsync: _vsync, value: 1.0);
  Animation<double> get visibilityAnimation => _visibilityController.view;

  late final _naturalElasticController = AnimationController(vsync: _vsync);
  Animation<double> get naturalElasticAnimation => _naturalElasticController.view;

  late final _restrictController = AnimationController(vsync: _vsync);
  Animation<double> get restrictAnimation => _restrictController.view;

  DartController({
    required TickerProvider vsync,
  }) : _vsync = vsync;

  Future<void> show() async {
    await _visibilityController.animateTo(1.0, duration: visibilityDuration);
  }

  Future<void> hide() async {
    await _visibilityController.animateTo(0.0, duration: visibilityDuration);
  }

  Future<void> animateElastic() async {
    _naturalElasticController.reset();
    _naturalElasticController.animateTo(
      1.0,
      duration: naturalElasticDuration,
      curve: naturalElasticCurve,
    );
  }

  Future<void> animateRestrict() async {
    _restrictController.reset();
    _restrictController.animateTo(
      1.0,
      duration: naturalElasticDuration,
      curve: naturalElasticCurve,
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

  final visibilityDuration = const Duration(milliseconds: 250);
  final visibilityCurve = Curves.linear;

  late final _visibilityController = AnimationController(vsync: _vsync);
  Animation<double> get visibilityAnimation => _visibilityController.view;

  TargetController({
    required TickerProvider vsync,
  }) : _vsync = vsync;

  Future<void> show() async {
    await _visibilityController.animateTo(
      1.0,
      duration: visibilityDuration,
      curve: visibilityCurve,
    );
  }

  Future<void> hide() async {
    await _visibilityController.animateTo(
      0.0,
      duration: visibilityDuration,
      curve: visibilityCurve,
    );
  }
}
