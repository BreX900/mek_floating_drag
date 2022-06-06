import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/floating_dart.dart';
import 'package:mek_floating_drag/src/fly_zone.dart';
import 'package:mek_floating_drag/src/fly_zone_controller.dart';

class FloatingBallTarget extends StatelessWidget {
  const FloatingBallTarget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingTarget(
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

class FloatingTarget extends StatefulWidget {
  final WidgetBuilder builder;

  const FloatingTarget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<FloatingTarget> createState() => _FloatingTargetState();
}

class _FloatingTargetState extends State<FloatingTarget> with TickerProviderStateMixin {
  FlyZoneController? _flyZoneController;
  late final TargetController _controller;

  final _childKey = GlobalKey();

  late Animation<double> _dartScaleAnimation;
  final _positionTween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
  late Animation<Offset> _dartPositionAnimation;

  @override
  void initState() {
    super.initState();

    _controller = TargetController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flyZoneController = FlyZone.of(context);

    if (_flyZoneController != flyZoneController) {
      _flyZoneController?.detachTarget(_controller);
      _flyZoneController = flyZoneController;
      _flyZoneController?.attachTarget(_controller);
    }
  }

  void _startDartAnimation(FloatingDartState dartState, Offset from, Offset to) async {
    final dartController = dartState.controller;

    _dartScaleAnimation = dartController.visibilityAnimation.drive(Tween(begin: 0.0, end: 1.0));
    _dartPositionAnimation = dartController.visibilityAnimation.drive(_positionTween
      ..begin = to
      ..end = from);

    dartController.hide();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildDartAnimation(BuildContext context, Widget? child) {
    final offset = _dartPositionAnimation.value;
    final scale = _dartScaleAnimation.value;

    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: Transform.scale(
        scale: scale,
        transformHitTests: false,
        child: child,
      ),
    );
  }

  Widget _buildFighter(BuildContext context) => widget.builder(context);

  @override
  Widget build(BuildContext context) {
    final target = DragTarget<FloatingDartState>(
      onWillAccept: (data) => data is FloatingDartState,
      onAccept: (dartState) {
        final containerBox = dartState.containerBox;
        final planeBox = dartState.childBox;

        final childBox = _childKey.currentContext!.findRenderObject() as RenderBox;
        final offset = dartState.controller.position.value;

        final childGlobalOffset = childBox
            .localToGlobal(childBox.size.center(Offset.zero) - planeBox.size.center(Offset.zero));
        final childInContainer = containerBox.globalToLocal(childGlobalOffset);

        _startDartAnimation(dartState, offset, childInContainer);

        dartState.builder = _buildDartAnimation;
      },
      builder: (context, candidate, rejected) {
        return _buildFighter(context);
      },
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
