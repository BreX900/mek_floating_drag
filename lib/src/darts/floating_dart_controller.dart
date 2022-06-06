import 'package:flutter/widgets.dart';

class FloatingDartController {
  final TickerProvider _vsync;
  Object? _animationKey;

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

  FloatingDartController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    Duration? visibilityDuration,
    Duration? naturalElasticDuration,
    Curve naturalElasticCurve = Curves.bounceOut,
    Duration restrictAfter = const Duration(seconds: 3),
    Duration? restrictDuration,
    Curve restrictCurve = Curves.linearToEaseOut,
  })  : _vsync = vsync,
        _visibilityDuration = visibilityDuration ?? duration,
        _naturalElasticDuration = naturalElasticDuration ?? duration,
        _naturalElasticCurve = naturalElasticCurve,
        _restrictDuration = restrictDuration ?? duration,
        _restrictCurve = restrictCurve {
    naturalElasticAnimation.addStatusListener((status) async {
      switch (status) {
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.completed:
          final animationKey = Object();
          _animationKey = animationKey;
          await Future.delayed(restrictAfter);
          if (_animationKey != animationKey) return;
          animateRestrict();
          break;
      }
    });
  }

  Future<void> show() async {
    await _visibilityController.animateTo(1.0, duration: _visibilityDuration);
  }

  Future<void> hide() async {
    await _visibilityController.animateTo(0.0, duration: _visibilityDuration);
  }

  Future<void> animateElastic() async {
    if (_naturalElasticController.isAnimating) return;
    _animationKey = null;
    _restrictController.stop();
    _naturalElasticController.reset();

    await _naturalElasticController.animateTo(
      1.0,
      duration: _naturalElasticDuration,
      curve: _naturalElasticCurve,
    );
  }

  Future<void> animateRestrict() async {
    if (_restrictController.isAnimating) return;
    _animationKey = null;
    _naturalElasticController.stop();
    _restrictController.reset();

    await _restrictController.animateTo(
      1.0,
      duration: _restrictDuration,
      curve: _restrictCurve,
    );
  }

  void dragStart() {
    _animationKey = null;
    _naturalElasticController.stop();
    _restrictController.stop();

    isDragging.value = true;
  }

  void dragUpdate(Offset delta) {
    position.value += delta;
  }

  void dragEnd() {
    isDragging.value = false;
  }

  /// Internal
  void updatePosition(Offset value) {
    position.value = value;
  }

  void dispose() {
    _naturalElasticController.dispose();
    _restrictController.dispose();
  }
}
