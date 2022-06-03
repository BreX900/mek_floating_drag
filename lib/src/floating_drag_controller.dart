import 'package:flutter/widgets.dart';

typedef PlaneBuilder = Widget Function(BuildContext context, Widget child);

class FlyZone extends InheritedWidget {
  final FlyZoneController controller;

  const FlyZone({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  static FlyZoneController of(BuildContext context, {bool listen = true}) {
    FlyZone flyZone;
    if (listen) {
      flyZone = context.dependOnInheritedWidgetOfExactType<FlyZone>()!;
    } else {
      flyZone = context.findAncestorWidgetOfExactType<FlyZone>()!;
    }
    return flyZone.controller;
  }

  @override
  bool updateShouldNotify(FlyZone oldWidget) => controller != oldWidget.controller;
}

class DefaultFlyZone extends StatefulWidget {
  final Offset initialPosition;
  final Widget child;

  const DefaultFlyZone({
    Key? key,
    this.initialPosition = const Offset(20.0, 20.0),
    required this.child,
  }) : super(key: key);

  @override
  State<DefaultFlyZone> createState() => _DefaultFlyZoneState();
}

class _DefaultFlyZoneState extends State<DefaultFlyZone> with TickerProviderStateMixin {
  late FlyZoneController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlyZoneController(vsync: this);
  }

  @override
  void didUpdateWidget(DefaultFlyZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != oldWidget.initialPosition) {
      _controller.dispose();
      _controller = FlyZoneController(
        initialPosition: widget.initialPosition,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlyZone(
      controller: _controller,
      child: widget.child,
    );
  }
}

class FlyZoneController {
  final TickerProvider _ticker;

  final isDragging = ValueNotifier<bool>(false);
  final ValueNotifier<Offset> planePosition;
  final planeBuilder = ValueNotifier<PlaneBuilder?>(null);

  late final planeVisibility = AnimationController(
    vsync: _ticker,
    duration: const Duration(milliseconds: 250),
    value: 1.0,
  );
  late final fighterVisibility = AnimationController(
    vsync: _ticker,
    duration: const Duration(milliseconds: 500),
  );

  FlyZoneController({
    required TickerProvider vsync,
    Offset initialPosition = const Offset(20.0, 20.0),
  })  : _ticker = vsync,
        planePosition = ValueNotifier<Offset>(initialPosition) {
    isDragging.addListener(_listener);
  }

  void show() async {
    await planeVisibility.forward();
    planeBuilder.value = null;
  }

  void _listener() {
    if (isDragging.value) {
      fighterVisibility.forward();
    } else {
      fighterVisibility.reverse();
    }
  }

  void dispose() {
    isDragging.dispose();
    planePosition.dispose();
    planePosition.dispose();
    planeVisibility.dispose();
    fighterVisibility.dispose();
  }
}
