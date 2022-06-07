import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zones/floating_zone_controller.dart';
import 'package:mek_floating_drag/src/fly_zones/floating_zone_scope.dart';

abstract class FloatingZone implements Widget {
  const factory FloatingZone({
    Key? key,
    FloatingZoneController? controller,
    required Widget child,
  }) = _BasicFloatingZone;

  const factory FloatingZone.inStack({
    Key? key,
    FloatingZoneController? controller,
    required List<Widget> entries,
    required Widget child,
  }) = _FloatingZoneInStack;

  const factory FloatingZone.inOverlay({
    Key? key,
    FloatingZoneController? controller,
    required List<Widget> entries,
    required Widget child,
  }) = _FloatingZoneInOverlay;

  static FloatingZoneScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FloatingZoneScope>();
  }
}

class _BasicFloatingZone extends StatefulWidget implements FloatingZone {
  final FloatingZoneController? controller;
  final void Function(FloatingZoneController controller, ValueGetter<RenderBox> renderBoxGetter)?
      onSetup;
  final Widget child;

  const _BasicFloatingZone({
    Key? key,
    this.controller,
    this.onSetup,
    required this.child,
  }) : super(key: key);

  @override
  State<_BasicFloatingZone> createState() => _BasicFloatingZoneState();
}

class _BasicFloatingZoneState extends State<_BasicFloatingZone> {
  late FloatingZoneController _controller;

  @override
  void initState() {
    super.initState();
    ConstrainedBox;
    _controller = FloatingZoneController();
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
    return FloatingZoneScope(
      controller: widget.controller ?? _controller,
      renderBoxGetter: getRenderBox,
      child: widget.child,
    );
  }
}

class _FloatingZoneInStack extends StatelessWidget implements FloatingZone {
  final FloatingZoneController? controller;
  final List<Widget> entries;
  final Widget child;

  const _FloatingZoneInStack({
    Key? key,
    this.controller,
    required this.entries,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BasicFloatingZone(
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

class _FloatingZoneInOverlay extends StatefulWidget implements FloatingZone {
  final FloatingZoneController? controller;
  final List<Widget> entries;
  final Widget child;

  const _FloatingZoneInOverlay({
    Key? key,
    this.controller,
    required this.entries,
    required this.child,
  }) : super(key: key);

  @override
  State<_FloatingZoneInOverlay> createState() => _FloatingZoneInOverlayState();
}

class _FloatingZoneInOverlayState extends State<_FloatingZoneInOverlay> {
  late final OverlayEntry _entry;

  FloatingZoneController? _controller;
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
  void didUpdateWidget(_FloatingZoneInOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _entry.remove();

    super.dispose();
  }

  Widget _buildEntries(BuildContext context) {
    return _BasicFloatingZone(
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
    return FloatingZoneScope(
      controller: _controller!,
      renderBoxGetter: _renderBoxGetter!,
      child: widget.child,
    );
  }
}
