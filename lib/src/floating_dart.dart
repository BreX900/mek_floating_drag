import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone.dart';
import 'package:mek_floating_drag/src/fly_zone_controller.dart';
import 'package:mek_floating_drag/src/utils/offset_resolver.dart';

typedef FloatingDartBuilder = Widget Function(BuildContext context, Widget child);

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
  late final _childEntry = OverlayEntry(
    builder: _build,
  );

  FlyZoneController? _flyZoneController;
  late final DartController _controller;
  DartController get controller => _controller;

  Animation<Offset>? _naturalElasticAnimation;
  Animation<Offset>? _restrictAnimation;

  final _childKey = GlobalKey();

  RenderBox get containerBox => context.findRenderObject() as RenderBox;
  RenderBox get childBox => _childKey.currentContext!.findRenderObject() as RenderBox;

  TransitionBuilder? _builder;

  set builder(TransitionBuilder value) {
    setState(() => _builder = value);
  }

  final _draggableKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _controller = DartController(vsync: this);

    _overlayEntries.addAll(widget.builders.map((e) => OverlayEntry(builder: e)));
    _overlayEntries.add(_childEntry);

    _controller.naturalElasticAnimation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          _startNaturalElasticAnimation();
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.dismissed:
          setState(() => _naturalElasticAnimation = null);
          break;
        case AnimationStatus.completed:
          setState(() => _naturalElasticAnimation = null);
          _controller.animateRestrict();
          break;
      }
    });
    _controller.naturalElasticAnimation.addListener(() {
      if (_naturalElasticAnimation == null) return;
      _controller.position.value = _naturalElasticAnimation!.value;
    });

    _controller.restrictAnimation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          _startRestrictAnimation();
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.dismissed:
          setState(() => _restrictAnimation = null);
          break;
        case AnimationStatus.completed:
          setState(() => _restrictAnimation = null);
          break;
      }
    });
    _controller.restrictAnimation.addListener(() {
      if (_restrictAnimation == null) return;
      _controller.position.value = _restrictAnimation!.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flyZoneController = FlyZone.of(context);

    if (_flyZoneController != flyZoneController) {
      _flyZoneController?.detachDart(_controller);
      _flyZoneController = flyZoneController;
      _flyZoneController?.attachDart(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startNaturalElasticAnimation() {
    final containerSize = containerBox.size;
    final childSize = childBox.size;
    final currentOffset = controller.position.value;
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

    setState(() {
      _naturalElasticAnimation = _controller.naturalElasticAnimation.drive(Tween(
        begin: currentOffset,
        end: targetOffset,
      ));
    });
  }

  void _startRestrictAnimation() {
    final containerSize = containerBox.size;
    final childSize = childBox.size;
    final currentOffset = controller.position.value;

    final offsetResolver = OffsetResolver(
      containerSize: containerSize,
      childSize: childBox.size,
    );

    // Retracted Edges
    final retractEdges = widget.retractEdgesResolver(containerSize, childSize);
    final retractedOffset = offsetResolver.getRetractedTarget(currentOffset, retractEdges);

    setState(() {
      _restrictAnimation = _controller.restrictAnimation.drive(Tween(
        begin: currentOffset,
        end: retractedOffset,
      ));
    });
  }

  void _onPanStart() {
    _controller.dragStart();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller.dragUpdate(details.delta);
  }

  void _onPanEnd(DraggableDetails details) {
    _controller.dragEnd();

    if (_builder != null) return;

    _controller.animateElastic();
  }

  Widget _buildPositioned(BuildContext context, Offset offset, Widget? child) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: child!,
    );
  }

  Widget _build(BuildContext context) {
    // if (!_controller.isVisible.value) return const SizedBox.shrink();

    Widget current = KeyedSubtree(
      key: _childKey,
      child: widget.builder(context),
    );

    current = Draggable(
      key: _draggableKey,
      rootOverlay: false,
      data: this,
      childWhenDragging: const SizedBox.shrink(),
      feedback: current,
      onDragStarted: _onPanStart,
      onDragUpdate: _onPanUpdate,
      onDragEnd: _onPanEnd,
      child: current,
    );

    final animationBuilder = _builder;

    if (animationBuilder != null) {
      return AnimatedBuilder(
        animation: controller.visibilityAnimation,
        builder: animationBuilder,
        child: current,
      );
    }

    if (_naturalElasticAnimation != null) {
      return ValueListenableBuilder<Offset>(
        valueListenable: _naturalElasticAnimation!,
        builder: _buildPositioned,
        child: current,
      );
    }
    if (_restrictAnimation != null) {
      return ValueListenableBuilder<Offset>(
        valueListenable: _restrictAnimation!,
        builder: _buildPositioned,
        child: current,
      );
    }

    return _buildPositioned(context, controller.position.value, current);
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: _overlayEntries,
    );
  }
}
