import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zone/fly_zone_controller.dart';
import 'package:mek_floating_drag/src/fly_zone/fly_zone_scope.dart';

abstract class FlyZone implements Widget {
  const factory FlyZone({
    Key? key,
    FlyZoneController? controller,
    required Widget child,
  }) = _BasicFlyZone;

  const factory FlyZone.inStack({
    Key? key,
    FlyZoneController? controller,
    required List<Widget> entries,
    required Widget child,
  }) = _FlyZoneInStack;

  const factory FlyZone.inOverlay({
    Key? key,
    FlyZoneController? controller,
    required List<Widget> entries,
    required Widget child,
  }) = _FlyZoneInOverlay;

  static FlyZoneScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FlyZoneScope>();
  }
}

class _BasicFlyZone extends StatefulWidget implements FlyZone {
  final FlyZoneController? controller;
  final void Function(FlyZoneController controller, ValueGetter<RenderBox> renderBoxGetter)?
      onSetup;
  final Widget child;

  const _BasicFlyZone({
    Key? key,
    this.controller,
    this.onSetup,
    required this.child,
  }) : super(key: key);

  @override
  State<_BasicFlyZone> createState() => _BasicFlyZoneState();
}

class _BasicFlyZoneState extends State<_BasicFlyZone> {
  late FlyZoneController _controller;

  @override
  void initState() {
    super.initState();
    ConstrainedBox;
    _controller = FlyZoneController();
    widget.onSetup?.call(_controller, getRenderBox);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  RenderBox getRenderBox() => context.findRenderObject() as RenderBox;

  @override
  Widget build(BuildContext context) {
    Draggable;
    DragTarget;
    return FlyZoneScope(
      controller: widget.controller ?? _controller,
      renderBoxGetter: getRenderBox,
      child: widget.child,
    );
  }
}

class _FlyZoneInStack extends StatelessWidget implements FlyZone {
  final FlyZoneController? controller;
  final List<Widget> entries;
  final Widget child;

  const _FlyZoneInStack({
    Key? key,
    this.controller,
    required this.entries,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BasicFlyZone(
      controller: controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          ...entries,
        ],
      ),
    );
  }
}

class _FlyZoneInOverlay extends StatefulWidget implements FlyZone {
  final FlyZoneController? controller;
  final List<Widget> entries;
  final Widget child;

  const _FlyZoneInOverlay({
    Key? key,
    this.controller,
    required this.entries,
    required this.child,
  }) : super(key: key);

  @override
  State<_FlyZoneInOverlay> createState() => _FlyZoneInOverlayState();
}

class _FlyZoneInOverlayState extends State<_FlyZoneInOverlay> {
  late final OverlayEntry _entry;

  FlyZoneController? _controller;
  RenderBox Function()? _renderBoxGetter;

  @override
  void initState() {
    super.initState();

    _entry = OverlayEntry(builder: _buildEntries);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Overlay.of(context)!.insert(_entry);
    });
  }

  @override
  void didUpdateWidget(_FlyZoneInOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _entry.remove();

    super.dispose();
  }

  Widget _buildEntries(BuildContext context) {
    return _BasicFlyZone(
      controller: widget.controller,
      onSetup: (controller, renderBoxGetter) {
        if (_controller == controller && _renderBoxGetter == renderBoxGetter) return;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _controller = controller;
            _renderBoxGetter = renderBoxGetter;
          });
        });
      },
      child: Stack(
        children: widget.entries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _renderBoxGetter == null) {
      return widget.child;
    }
    return FlyZoneScope(
      controller: _controller!,
      renderBoxGetter: _renderBoxGetter!,
      child: widget.child,
    );
  }
}
