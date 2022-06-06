import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/darts/floating_dart_controller.dart';
import 'package:mek_floating_drag/src/fly_zones/fly_zone.dart';
import 'package:mek_floating_drag/src/utils/listener_subscription.dart';
import 'package:mek_floating_drag/src/utils/offset_resolver.dart';

typedef FloatingEdgesResolver = EdgeInsets Function(Size containerSize, Size childSize);

class FloatingDart extends StatefulWidget {
  final FloatingDartController? controller;
  final FloatingEdgesResolver retractEdgesResolver;
  final FloatingEdgesResolver elasticEdgesResolver;
  final FloatingEdgesResolver naturalEdgesResolver;
  final Widget child;

  const FloatingDart({
    Key? key,
    this.controller,
    this.retractEdgesResolver = buildEmptyEdges,
    this.elasticEdgesResolver = buildEmptyEdges,
    this.naturalEdgesResolver = buildEmptyEdges,
    required this.child,
  }) : super(key: key);

  static EdgeInsets buildEmptyEdges(Size _, Size __) {
    return const EdgeInsets.all(double.nan);
  }

  @override
  State<FloatingDart> createState() => FloatingDartState();
}

class FloatingDartState extends State<FloatingDart> with TickerProviderStateMixin {
  FlyZoneScope? _maybeFlyZone;
  FlyZoneScope get _flyZone => _maybeFlyZone!;

  FloatingDartController? _internalController;
  FloatingDartController get controller => (widget.controller ?? _internalController)!;

  final subscriptions = <ListenerSubscription>[];

  Animation<Offset>? _naturalElasticAnimation;
  Animation<Offset>? _restrictAnimation;

  RenderBox get renderBox => context.findRenderObject() as RenderBox;

  TransitionBuilder? _builder;

  set builder(TransitionBuilder? value) {
    if (_builder == value) return;
    setState(() => _builder = value);
  }

  final _draggableKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) _internalController = FloatingDartController(vsync: this);

    _initControllerListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flyZone = FlyZone.of(context);

    if (_maybeFlyZone?.controller != flyZone.controller) {
      _maybeFlyZone?.controller.detachDart(controller);
      _maybeFlyZone = flyZone;
      _maybeFlyZone?.controller.attachDart(controller);
    }
  }

  @override
  void didUpdateWidget(FloatingDart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disposeControllerListeners();
      _flyZone.controller.detachDart((oldWidget.controller ?? _internalController)!);
      _flyZone.controller.attachDart(controller);
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
    controller.visibilityAnimation.listenStatus((status) {
      switch (status) {
        case AnimationStatus.dismissed:
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          builder = null;
          break;
      }
    }).addTo(subscriptions);

    controller.naturalElasticAnimation.listenStatus((status) {
      switch (status) {
        case AnimationStatus.forward:
          _startNaturalElasticAnimation();
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.dismissed:
          if (_naturalElasticAnimation == null) return;
          controller.position.value = _naturalElasticAnimation!.value;
          setState(() => _naturalElasticAnimation = null);
          break;
        case AnimationStatus.completed:
          if (_naturalElasticAnimation == null) return;
          controller.position.value = _naturalElasticAnimation!.value;
          setState(() => _naturalElasticAnimation = null);
          break;
      }
    }).addTo(subscriptions);

    controller.restrictAnimation.listenStatus((status) {
      switch (status) {
        case AnimationStatus.forward:
          _startRestrictAnimation();
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.dismissed:
          if (_restrictAnimation == null) return;
          controller.position.value = _restrictAnimation!.value;
          setState(() => _restrictAnimation = null);
          break;
        case AnimationStatus.completed:
          if (_restrictAnimation == null) return;
          controller.position.value = _restrictAnimation!.value;
          setState(() => _restrictAnimation = null);
          break;
      }
    }).addTo(subscriptions);
  }

  void _disposeControllerListeners() {
    subscriptions.close();
  }

  void _startNaturalElasticAnimation() {
    final containerSize = _flyZone.renderBox.size;
    final childSize = renderBox.size;
    final localCurrentOffset = controller.position.value;
    final currentOffset =
        _flyZone.renderBox.globalToLocal(renderBox.localToGlobal(localCurrentOffset));

    var targetOffset = currentOffset;

    final offsetResolver = OffsetResolver(
      containerSize: containerSize,
      childSize: renderBox.size,
    );

    // Elastic Edges
    final elasticEdges = widget.elasticEdgesResolver(containerSize, childSize);
    targetOffset = offsetResolver.getElasticTarget(targetOffset, elasticEdges);

    // Natural Edges
    final naturalEdges = widget.naturalEdgesResolver(containerSize, childSize);
    targetOffset = offsetResolver.getNaturalTarget(targetOffset, naturalEdges);

    final localTargetOffset =
        renderBox.globalToLocal(_flyZone.renderBox.localToGlobal(targetOffset));

    setState(() {
      _naturalElasticAnimation = controller.naturalElasticAnimation.drive(Tween(
        begin: localCurrentOffset,
        end: localTargetOffset,
      ));
    });
  }

  void _startRestrictAnimation() {
    final containerSize = _flyZone.renderBox.size;
    final childSize = renderBox.size;
    final localCurrentOffset = controller.position.value;
    final currentOffset =
        _flyZone.renderBox.globalToLocal(renderBox.localToGlobal(localCurrentOffset));

    final offsetResolver = OffsetResolver(
      containerSize: containerSize,
      childSize: renderBox.size,
    );

    // Retracted Edges
    final retractEdges = widget.retractEdgesResolver(containerSize, childSize);
    final retractedOffset = offsetResolver.getRetractedTarget(currentOffset, retractEdges);

    final localRetractedOffset =
        renderBox.globalToLocal(_flyZone.renderBox.localToGlobal(retractedOffset));

    setState(() {
      _restrictAnimation = controller.restrictAnimation.drive(Tween(
        begin: localCurrentOffset,
        end: localRetractedOffset,
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

  Widget _buildAppearAnimation(BuildContext context, Widget child) {
    return AnimatedBuilder(
      animation: controller.visibilityAnimation,
      child: child,
      builder: (context, child) {
        return Transform.scale(
          scale: controller.visibilityAnimation.value,
          child: child,
        );
      },
    );
  }

  Widget _buildPositioned(BuildContext context, Offset offset, Widget? child) {
    return Transform.translate(
      offset: offset,
      child: _buildAppearAnimation(context, child!),
    );
  }

  Widget _buildListeningPositionChanges(BuildContext context, Widget child) {
    return ValueListenableBuilder<Offset>(
      valueListenable: controller.position,
      builder: _buildPositioned,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget current = widget.child;

    current = Draggable(
      key: _draggableKey,
      rootOverlay: false,
      data: this,
      childWhenDragging: Visibility(
        visible: false,
        maintainState: true,
        maintainSize: true,
        maintainAnimation: true,
        child: current,
      ),
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

    return _buildListeningPositionChanges(context, current);
  }
}
