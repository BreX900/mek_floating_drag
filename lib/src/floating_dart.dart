import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone.dart';
import 'package:mek_floating_drag/src/fly_zone_controller.dart';
import 'package:mek_floating_drag/src/utils/listener_subscription.dart';
import 'package:mek_floating_drag/src/utils/offset_resolver.dart';

typedef FloatingDartBuilder = Widget Function(BuildContext context, Widget child);

typedef FloatingEdgesResolver = EdgeInsets Function(Size containerSize, Size childSize);

class FloatingDart extends StatefulWidget {
  final DartController? controller;
  final FloatingEdgesResolver retractEdgesResolver;
  final FloatingEdgesResolver elasticEdgesResolver;
  final FloatingEdgesResolver naturalEdgesResolver;
  final List<WidgetBuilder> builders;
  final WidgetBuilder builder;

  const FloatingDart({
    Key? key,
    this.controller,
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
  DartController? _internalController;
  DartController get controller => (widget.controller ?? _internalController)!;

  final subscriptions = <ListenerSubscription>[];

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

    if (widget.controller == null) _internalController = DartController(vsync: this);

    _overlayEntries.addAll(widget.builders.map((e) => OverlayEntry(builder: e)));
    _overlayEntries.add(_childEntry);

    _initControllerListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flyZoneController = FlyZone.of(context);

    if (_flyZoneController != flyZoneController) {
      _flyZoneController?.detachDart(controller);
      _flyZoneController = flyZoneController;
      _flyZoneController?.attachDart(controller);
    }
  }

  @override
  void didUpdateWidget(FloatingDart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disposeControllerListeners();
      _flyZoneController?.detachDart((oldWidget.controller ?? _internalController)!);
      _flyZoneController?.attachDart(controller);
      _initControllerListeners();
    }
  }

  @override
  void dispose() {
    _disposeControllerListeners();
    _internalController?.dispose();
    super.dispose();
  }

  void _initControllerListeners() {
    controller.naturalElasticAnimation.listenStatus((status) {
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
          break;
      }
    }).addTo(subscriptions);
    controller.naturalElasticAnimation.listen(() {
      if (_naturalElasticAnimation == null) return;
      controller.position.value = _naturalElasticAnimation!.value;
    }).addTo(subscriptions);

    controller.restrictAnimation.listenStatus((status) {
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
    }).addTo(subscriptions);
    controller.restrictAnimation.listen(() {
      if (_restrictAnimation == null) return;
      controller.position.value = _restrictAnimation!.value;
    }).addTo(subscriptions);
  }

  void _disposeControllerListeners() {
    subscriptions.close();
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
      _naturalElasticAnimation = controller.naturalElasticAnimation.drive(Tween(
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
      _restrictAnimation = controller.restrictAnimation.drive(Tween(
        begin: currentOffset,
        end: retractedOffset,
      ));
    });
  }

  void _onPanStart() {
    controller.dragStart();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    controller.dragUpdate(details.delta);
  }

  void _onPanEnd(DraggableDetails details) {
    controller.dragEnd();

    if (_builder != null) return;

    controller.animateElastic();
  }

  Widget _buildPositioned(BuildContext context, Offset offset, Widget? child) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: child!,
    );
  }

  Widget _build(BuildContext context) {
    // TODO: Remove widget on tree when it is never visible
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
    NotificationListener;
    ScrollNotification;
    ScrollController;

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
