import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone.dart';
import 'package:mek_floating_drag/src/fly_zone_controller.dart';
import 'package:mek_floating_drag/src/utils/offset_resolver.dart';

typedef FloatingEdgesResolver = EdgeInsets Function(Size containerSize, Size childSize);

class FloatingDart extends StatefulWidget {
  final Duration elasticDuration;
  final Curve elasticCurve;
  final FloatingEdgesResolver retractEdgesResolver;
  final FloatingEdgesResolver elasticEdgesResolver;
  final FloatingEdgesResolver naturalEdgesResolver;
  final List<WidgetBuilder> builders;
  final WidgetBuilder builder;

  const FloatingDart({
    Key? key,
    this.elasticDuration = const Duration(milliseconds: 500),
    this.elasticCurve = Curves.bounceOut,
    this.retractEdgesResolver = buildEmptyEdges,
    this.elasticEdgesResolver = buildEmptyEdges,
    this.naturalEdgesResolver = buildEmptyEdges,
    this.builders = const <WidgetBuilder>[],
    required this.builder,
  }) : super(key: key);

  static EdgeInsets buildEmptyEdges(Size _, Size __) {
    return const EdgeInsets.all(double.nan);
  }

  @override
  State<FloatingDart> createState() => FloatingDartState();
}

class FloatingDartState extends State<FloatingDart> with TickerProviderStateMixin {
  final _overlayEntries = <OverlayEntry>[];

  FlyZoneController? _controller;

  final _childKey = GlobalKey();
  late final _childEntry = OverlayEntry(
    builder: _build,
  );

  Object? _animationKey;
  late AnimationController _positionController;
  Animation<Offset>? _positionAnimation;

  bool _isVisible = true;
  // Required because a Draggable widget is moved on widget tree
  final _draggableKey = GlobalKey();

  RenderBox get containerBox => context.findRenderObject() as RenderBox;

  RenderBox get childBox => _childKey.currentContext!.findRenderObject() as RenderBox;

  @override
  void initState() {
    super.initState();

    _overlayEntries.addAll(widget.builders.map((e) => OverlayEntry(builder: e)));
    _overlayEntries.add(_childEntry);

    _positionController = AnimationController(vsync: this);

    _positionController.addListener(() {
      if (_positionAnimation == null) return;
      _controller!.dartPosition.value = _positionAnimation!.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = FlyZone.of(context);

    if (_controller != controller) {
      _controller?.dartVisibility.removeListener(_listenVisibility);
      _controller = controller;
      _controller!.dartVisibility.addListener(_listenVisibility);
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  void _listenVisibility() {
    final value = _controller!.dartVisibility.value;
    _isVisible = value > 0;
    _childEntry.markNeedsBuild();
  }

  void _stopAnimation() {
    _animationKey = null;
    _positionController.reset();
  }

  void _startAnimation(Offset currentOffset, Offset elasticOffset, Offset retractedOffset) async {
    final animationKey = Object();
    _animationKey = animationKey;

    await _animateBetween(
      currentOffset,
      elasticOffset,
      duration: widget.elasticDuration,
      curve: widget.elasticCurve,
    );

    if (elasticOffset == retractedOffset) return;

    await Future.delayed(const Duration(seconds: 2));

    if (_animationKey != animationKey) return;
    await _animateBetween(
      elasticOffset,
      retractedOffset,
      duration: widget.elasticDuration,
      curve: Curves.linear,
    );
  }

  Future<void> _animateBetween(
    Offset from,
    Offset to, {
    required Duration duration,
    required Curve curve,
  }) async {
    _positionAnimation = _positionController.drive(Tween(
      begin: from,
      end: to,
    ));
    await _positionController.animateTo(
      1.0,
      duration: duration,
      curve: curve,
    );

    _positionAnimation = null;
    _positionController.reset();
  }

  void _onPanStart() {
    _stopAnimation();
    _controller!.isDartDragging.value = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller!.dartPosition.value += details.delta;
  }

  void _onPanEnd(DraggableDetails details) {
    _controller!.isDartDragging.value = false;

    if (_controller!.dartBuilder.value != null) return;

    final containerSize = containerBox.size;
    final childSize = childBox.size;
    final currentOffset = _controller!.dartPosition.value;
    var targetOffset = currentOffset;

    final offsetResolver = OffsetResolver(
      containerSize: containerSize,
      childSize: childBox.size,
    );

    // Elastic Edges
    final elasticEdges = widget.elasticEdgesResolver(containerSize, childSize);
    targetOffset = offsetResolver.getElasticTarget(targetOffset, elasticEdges);

    // Natural Edges
    final naturalEdges = widget.naturalEdgesResolver(containerSize, childSize);
    targetOffset = offsetResolver.getNaturalTarget(targetOffset, naturalEdges);

    // Retracted Edges
    final retractEdges = widget.retractEdgesResolver(containerSize, childSize);
    final retractedOffset = offsetResolver.getRetractedTarget(targetOffset, retractEdges);

    _startAnimation(currentOffset, targetOffset, retractedOffset);
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
      valueListenable: _controller!.isDartDragging,
      child: draggable,
      builder: (context, isDragging, child) {
        if (isDragging) {
          return _buildPositioned(_controller!.dartPosition.value, child!);
        }
        return ValueListenableBuilder(
          valueListenable: _controller!.dartBuilder,
          child: child,
          builder: (context, planeBuilder, child) {
            final planeBuilder = _controller!.dartBuilder.value;

            if (planeBuilder != null) {
              return planeBuilder(context, child!);
            }

            return ValueListenableBuilder<Offset>(
              valueListenable: _controller!.dartPosition,
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
