import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/floating_drag.dart';
import 'package:mek_floating_drag/src/floating_drag_controller.dart';

class FighterMark extends StatefulWidget {
  const FighterMark({Key? key}) : super(key: key);

  @override
  State<FighterMark> createState() => _FighterMarkState();
}

class _FighterMarkState extends State<FighterMark> with TickerProviderStateMixin {
  FlyZoneController? _controller;

  final _childKey = GlobalKey();
  late Animation<double> _scaleAnimation;
  final _positionTween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
  late Animation<Offset> _positionAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = FlyZone.of(context);

    if (_controller != controller) {
      _controller = controller;
      _initAnimation();
    }
  }

  void _initAnimation() {
    _scaleAnimation = _controller!.planeVisibility.drive(Tween(begin: 0.0, end: 1.0));
    _positionAnimation = _controller!.planeVisibility.drive(_positionTween);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildEndAnimation(BuildContext context, Widget child) {
    final animatedVisibility = AnimatedBuilder(
      animation: _controller!.planeVisibility,
      child: child,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          transformHitTests: false,
          child: child,
        );
      },
    );

    return ValueListenableBuilder<Offset>(
      valueListenable: _positionAnimation,
      child: animatedVisibility,
      builder: (context, offset, child) {
        return Positioned(
          top: offset.dy,
          left: offset.dx,
          child: child!,
        );
      },
    );
  }

  Widget _buildFighter(BuildContext context) {
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
  }

  @override
  Widget build(BuildContext context) {
    final target = DragTarget<PlaneState>(
      onWillAccept: (data) => data is PlaneState,
      onAccept: (data) {
        final containerBox = data.containerBox;
        final planeBox = data.childBox;

        final childBox = _childKey.currentContext!.findRenderObject() as RenderBox;
        final offset = _controller!.planePosition.value;

        final childGlobalOffset = childBox
            .localToGlobal(childBox.size.center(Offset.zero) - planeBox.size.center(Offset.zero));
        final childInContainer = containerBox.globalToLocal(childGlobalOffset);

        final childCenter = Offset(
          childInContainer.dx, // + childBox.size.width,
          childInContainer.dy, // + childBox.size.height,
        );

        _positionTween
          ..begin = childCenter
          ..end = offset;

        _controller!.planeBuilder.value = _buildEndAnimation;

        _controller!.planeVisibility.reverse();
      },
      builder: (context, candidate, rejected) {
        return _buildFighter(context);
      },
    );

    return AnimatedBuilder(
      animation: _controller!.fighterVisibility,
      child: target,
      builder: (context, child) {
        return Transform.scale(
          scale: _controller!.fighterVisibility.value,
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
