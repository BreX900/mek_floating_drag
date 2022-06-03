import 'package:flutter/widgets.dart';

// FloatingWidget / FloatingStack
class FloatingDrag extends StatefulWidget {
  final Offset initialOffset;
  final Duration elasticDuration;
  final Curve elasticCurve;
  final EdgeInsets Function(Size containerSize, Size childSize) elasticEdgesResolver;
  final EdgeInsets Function(Size containerSize, Size childSize) naturalEdgesResolver;
  final WidgetBuilder builder;

  const FloatingDrag({
    Key? key,
    this.initialOffset = const Offset(20.0, 20.0),
    this.elasticDuration = const Duration(milliseconds: 500),
    this.elasticCurve = Curves.bounceOut,
    this.elasticEdgesResolver = buildEmptyEdges,
    this.naturalEdgesResolver = buildEmptyEdges,
    required this.builder,
  }) : super(key: key);

  static EdgeInsets buildEmptyEdges(Size _, Size __) {
    return const EdgeInsets.all(double.nan);
  }

  @override
  State<FloatingDrag> createState() => _FloatingDragState();
}

class _FloatingDragState extends State<FloatingDrag> with TickerProviderStateMixin {
  final _overlayEntries = <OverlayEntry>[];

  final _childKey = GlobalKey();
  late final _childEntry = OverlayEntry(
    builder: _build,
  );
  late Offset _offset;
  late AnimationController _childPositionController;
  Animation<Offset>? _childPositionAnimation;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
    _childPositionController = AnimationController(vsync: this);
    _childPositionController.addListener(() {
      if (_childPositionAnimation == null) return;
      _offset = _childPositionAnimation!.value;
      _childEntry.markNeedsBuild();
    });
    _overlayEntries.add(_childEntry);
  }

  @override
  void didUpdateWidget(FloatingDrag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialOffset != oldWidget.initialOffset) {
      _offset = widget.initialOffset;
      _stopAnimation();
    }
  }

  @override
  void dispose() {
    _childPositionController.dispose();
    super.dispose();
  }

  void _stopAnimation() {
    _childPositionAnimation = null;
    _childPositionController.reset();
  }

  void _startAnimation(Offset from, Offset to) {
    _childPositionAnimation = _childPositionController.drive(Tween(
      begin: from,
      end: to,
    ));
    _childPositionController.animateTo(
      1.0,
      duration: widget.elasticDuration,
      curve: widget.elasticCurve,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _stopAnimation();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _offset = _offset + details.delta;
    _childEntry.markNeedsBuild();
  }

  void _onPanEnd(DragEndDetails details) {
    final containerBox = context.findRenderObject() as RenderBox;
    final childBox = _childKey.currentContext!.findRenderObject() as RenderBox;

    final containerSize = containerBox.size;
    final childSize = childBox.size;
    final currentOffset = _offset;

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

  Widget _build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Transform.translate(
        offset: _offset,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanEnd: _onPanEnd,
          onPanUpdate: _onPanUpdate,
          child: FittedBox(
            fit: BoxFit.none,
            child: KeyedSubtree(
              key: _childKey,
              child: widget.builder(context),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: _overlayEntries,
    );
  }
}
