import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/darts/floating_draggable.dart';
import 'package:mek_floating_drag/src/fly_zones/floating_zone.dart';
import 'package:mek_floating_drag/src/fly_zones/floating_zone_scope.dart';
import 'package:mek_floating_drag/src/targets/floating_target_controller.dart';
import 'package:mek_floating_drag/src/utils/listener_subscription.dart';

class FloatingDragBin extends StatefulWidget {
  final FloatingDragTargetController? controller;
  final WidgetBuilder builder;

  const FloatingDragBin({
    Key? key,
    this.controller,
    required this.builder,
  }) : super(key: key);

  @override
  State<FloatingDragBin> createState() => _FloatingDragBinState();
}

class _FloatingDragBinState extends State<FloatingDragBin> with TickerProviderStateMixin {
  FloatingZoneScope? _maybeZone;
  FloatingZoneScope get _zone => _maybeZone!;

  FloatingDragTargetController? _internalController;
  FloatingDragTargetController get _controller => (widget.controller ?? _internalController)!;

  final _childKey = GlobalKey();

  late Animation<double> _draggableScaleAnimation;
  final _draggablePositionTween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
  late Animation<Offset> _draggablePositionAnimation;

  @override
  void initState() {
    super.initState();

    _internalController = FloatingDragTargetController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flyZone = FloatingZone.of(context);

    if (_maybeZone != flyZone) {
      _maybeZone?.controller.detachDragTarget(_controller);
      _maybeZone = flyZone;
      _maybeZone?.controller.attachDragTarget(_controller);
    }
  }

  @override
  void didUpdateWidget(FloatingDragBin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _zone.controller.detachDragTarget((oldWidget.controller ?? _internalController)!);
      _zone.controller.attachDragTarget(_controller);
    }
  }

  void _startDraggableAnimation(FloatingDraggableState dartState, Offset from, Offset to) async {
    final draggableController = dartState.controller;

    _draggableScaleAnimation =
        draggableController.visibilityAnimation.drive(Tween(begin: 0.0, end: 1.0));
    _draggablePositionAnimation =
        draggableController.visibilityAnimation.drive(_draggablePositionTween
          ..begin = to
          ..end = from);

    late ListenerSubscription subscription;
    subscription = draggableController.visibilityAnimation.listenStatus((status) {
      switch (status) {
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
        case AnimationStatus.dismissed:
          draggableController.updatePosition(_draggablePositionAnimation.value);
          subscription.close();
          break;
      }
    });

    await draggableController.hide();
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  Widget _buildDartAnimation(BuildContext context, Widget? child) {
    final offset = _draggablePositionAnimation.value;
    final scale = _draggableScaleAnimation.value;

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
    final target = DragTarget<FloatingDraggableState>(
      onWillAccept: (data) => data is FloatingDraggableState,
      onAccept: (dartState) {
        final draggableBox = dartState.renderBox;
        final dragTargetBox = _childKey.currentContext!.findRenderObject() as RenderBox;
        final offset = dartState.controller.position.value;

        final localTarget =
            dragTargetBox.size.center(Offset.zero) - draggableBox.size.center(Offset.zero);
        final globalTarget = dragTargetBox.localToGlobal(localTarget);
        final localTargetInDart = draggableBox.globalToLocal(globalTarget);

        _startDraggableAnimation(dartState, offset, localTargetInDart);

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
