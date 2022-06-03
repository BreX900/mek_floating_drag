import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/floating_drag_controller.dart';

// FloatingWidget / FloatingStack
class Plane extends StatefulWidget {
  final Duration elasticDuration;
  final Curve elasticCurve;
  final EdgeInsets Function(Size containerSize, Size childSize) elasticEdgesResolver;
  final EdgeInsets Function(Size containerSize, Size childSize) naturalEdgesResolver;
  final List<WidgetBuilder> builders;
  final WidgetBuilder builder;

  const Plane({
    Key? key,
    this.elasticDuration = const Duration(milliseconds: 500),
    this.elasticCurve = Curves.bounceOut,
    this.elasticEdgesResolver = buildEmptyEdges,
    this.naturalEdgesResolver = buildEmptyEdges,
    this.builders = const <WidgetBuilder>[],
    required this.builder,
  }) : super(key: key);

  static EdgeInsets buildEmptyEdges(Size _, Size __) {
    return const EdgeInsets.all(double.nan);
  }

  @override
  State<Plane> createState() => PlaneState();
}

class PlaneState extends State<Plane> with TickerProviderStateMixin {
  final _overlayEntries = <OverlayEntry>[];

  FlyZoneController? _controller;

  final _childKey = GlobalKey();
  late final _childEntry = OverlayEntry(
    builder: _build,
  );

  late AnimationController _childPositionController;
  Animation<Offset>? _childPositionAnimation;

  bool _isVisible = true;
  // Required because a Draggable widget is moved on widget tree
  final _draggableKey = GlobalKey();

  RenderBox get containerBox {
    return context.findRenderObject() as RenderBox;
  }

  RenderBox get childBox {
    return _childKey.currentContext!.findRenderObject() as RenderBox;
  }

  @override
  void initState() {
    super.initState();

    _overlayEntries.addAll(widget.builders.map((e) => OverlayEntry(builder: e)));
    _overlayEntries.add(_childEntry);

    _childPositionController = AnimationController(vsync: this);

    _childPositionController.addListener(() {
      if (_childPositionAnimation == null) return;
      _controller!.planePosition.value = _childPositionAnimation!.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = FlyZone.of(context);

    if (_controller != controller) {
      _controller?.planeVisibility.removeListener(_listenPlaneVisibility);
      _controller = controller;
      _controller!.planeVisibility.addListener(_listenPlaneVisibility);
    }
  }

  @override
  void dispose() {
    _childPositionController.dispose();
    super.dispose();
  }

  void _listenPlaneVisibility() {
    final value = _controller!.planeVisibility.value;
    _isVisible = value > 0;
    _childEntry.markNeedsBuild();
  }

  void _stopAnimation() {
    _childPositionController.reset();
  }

  void _startAnimation(Offset from, Offset to) async {
    _childPositionAnimation = _childPositionController.drive(Tween(
      begin: from,
      end: to,
    ));
    await _childPositionController.animateTo(
      1.0,
      duration: widget.elasticDuration,
      curve: widget.elasticCurve,
    );

    _childPositionAnimation = null;
    _childPositionController.reset();
  }

  void _onPanStart() {
    _stopAnimation();
    _controller!.isDragging.value = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller!.planePosition.value += details.delta;
  }

  void _onPanEnd(DraggableDetails details) {
    _controller!.isDragging.value = false;

    if (_controller!.planeBuilder.value != null) return;

    final containerBox = context.findRenderObject() as RenderBox;
    final childBox = _childKey.currentContext!.findRenderObject() as RenderBox;

    final containerSize = containerBox.size;
    final childSize = childBox.size;
    final currentOffset = _controller!.planePosition.value;

    final isLeft = containerSize.width / 2 > currentOffset.dx;
    final isTop = containerSize.height / 2 > currentOffset.dy;

    var nextDx = currentOffset.dy;
    var nextDy = currentOffset.dy;

    // Elastic Edges

    final elasticEdges = widget.elasticEdgesResolver(containerSize, childSize);

    if (isLeft) {
      if (!elasticEdges.left.isNaN) nextDx = elasticEdges.left;
    } else {
      if (!elasticEdges.right.isNaN) {
        nextDx = containerSize.width - (childSize.width + elasticEdges.right);
      }
    }
    if (isTop) {
      if (!elasticEdges.top.isNaN) nextDy = elasticEdges.top;
    } else {
      if (!elasticEdges.bottom.isNaN) {
        nextDy = containerSize.height - (childSize.height + elasticEdges.bottom);
      }
    }

    // Natural Edges

    final naturalEdges = widget.naturalEdgesResolver(containerSize, childSize);

    if (isLeft) {
      if (!naturalEdges.left.isNaN) {
        if (currentOffset.dx < naturalEdges.left) nextDy = naturalEdges.left;
      }
    } else {
      if (!naturalEdges.right.isNaN) {
        final marginBottom = containerSize.width - (childSize.width + naturalEdges.right);
        if (currentOffset.dx > marginBottom) nextDy = marginBottom;
      }
    }
    if (isTop) {
      if (!naturalEdges.top.isNaN) {
        if (currentOffset.dy < naturalEdges.top) nextDy = naturalEdges.top;
      }
    } else {
      if (!naturalEdges.bottom.isNaN) {
        final marginBottom = containerSize.height - (childSize.height + naturalEdges.top);
        if (currentOffset.dy > marginBottom) nextDy = marginBottom;
      }
    }

    _startAnimation(currentOffset, Offset(nextDx, nextDy));
  }

  Widget _buildPositioned(Offset offset, Widget child) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: child,
    );
  }

  Widget _build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final child = KeyedSubtree(
      key: _childKey,
      child: widget.builder(context),
    );

    final draggable = Draggable(
      key: _draggableKey,
      rootOverlay: false,
      data: this,
      childWhenDragging: const SizedBox.shrink(),
      feedback: child,
      onDragStarted: _onPanStart,
      onDragUpdate: _onPanUpdate,
      onDragEnd: _onPanEnd,
      child: child,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: _controller!.isDragging,
      child: draggable,
      builder: (context, isDragging, child) {
        if (isDragging) {
          return _buildPositioned(_controller!.planePosition.value, child!);
        }
        return ValueListenableBuilder(
          valueListenable: _controller!.planeBuilder,
          child: child,
          builder: (context, planeBuilder, child) {
            final planeBuilder = _controller!.planeBuilder.value;

            if (planeBuilder != null) {
              return planeBuilder(context, child!);
            }

            return ValueListenableBuilder<Offset>(
              valueListenable: _controller!.planePosition,
              child: planeBuilder?.call(context, child!) ?? child!,
              builder: (context, offset, child) {
                return _buildPositioned(offset, child!);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: _overlayEntries,
    );
  }
}
