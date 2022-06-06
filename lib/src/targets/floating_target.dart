import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/darts/floating_dart.dart';
import 'package:mek_floating_drag/src/fly_zones/fly_zone.dart';
import 'package:mek_floating_drag/src/targets/floating_target_controller.dart';
import 'package:mek_floating_drag/src/utils/listener_subscription.dart';

class FloatingTarget extends StatefulWidget {
  final FloatingTargetController? controller;
  final WidgetBuilder builder;

  const FloatingTarget({
    Key? key,
    this.controller,
    required this.builder,
  }) : super(key: key);

  @override
  State<FloatingTarget> createState() => _FloatingTargetState();
}

class _FloatingTargetState extends State<FloatingTarget> with TickerProviderStateMixin {
  FlyZoneScope? _maybeFlyZone;
  FlyZoneScope get _flyZone => _maybeFlyZone!;

  FloatingTargetController? _internalController;
  FloatingTargetController get _controller => (widget.controller ?? _internalController)!;

  final _childKey = GlobalKey();

  late Animation<double> _dartScaleAnimation;
  final _positionTween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
  late Animation<Offset> _dartPositionAnimation;

  @override
  void initState() {
    super.initState();

    _internalController = FloatingTargetController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flyZone = FlyZone.of(context);

    if (_maybeFlyZone != flyZone) {
      _maybeFlyZone?.controller.detachTarget(_controller);
      _maybeFlyZone = flyZone;
      _maybeFlyZone?.controller.attachTarget(_controller);
    }
  }

  @override
  void didUpdateWidget(FloatingTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _flyZone.controller.detachTarget((oldWidget.controller ?? _internalController)!);
      _flyZone.controller.attachTarget(_controller);
    }
  }

  void _startDartAnimation(FloatingDartState dartState, Offset from, Offset to) async {
    final dartController = dartState.controller;

    _dartScaleAnimation = dartController.visibilityAnimation.drive(Tween(begin: 0.0, end: 1.0));
    _dartPositionAnimation = dartController.visibilityAnimation.drive(_positionTween
      ..begin = to
      ..end = from);

    late ListenerSubscription subscription;
    subscription = dartController.visibilityAnimation.listenStatus((status) {
      switch (status) {
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
        case AnimationStatus.dismissed:
          dartController.updatePosition(_dartPositionAnimation.value);
          subscription.close();
          break;
      }
    });

    await dartController.hide();
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  Widget _buildDartAnimation(BuildContext context, Widget? child) {
    final offset = _dartPositionAnimation.value;
    final scale = _dartScaleAnimation.value;

    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        transformHitTests: false,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = DragTarget<FloatingDartState>(
      onWillAccept: (data) => data is FloatingDartState,
      onAccept: (dartState) {
        final dartBox = dartState.renderBox;

        final targetBox = _childKey.currentContext!.findRenderObject() as RenderBox;
        final offset = dartState.controller.position.value;

        final localTarget = targetBox.size.center(Offset.zero) - dartBox.size.center(Offset.zero);
        final globalTarget = targetBox.localToGlobal(localTarget);
        final localTargetInDart = dartBox.globalToLocal(globalTarget);

        _startDartAnimation(dartState, offset, localTargetInDart);

        dartState.builder = _buildDartAnimation;
      },
      builder: (context, candidate, rejected) => widget.builder(context),
    );

    return AnimatedBuilder(
      animation: _controller.visibilityAnimation,
      child: target,
      builder: (context, child) {
        return Transform.scale(
          scale: _controller.visibilityAnimation.value,
          child: Center(
            child: KeyedSubtree(
              key: _childKey,
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
