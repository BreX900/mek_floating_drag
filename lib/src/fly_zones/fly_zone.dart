import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/fly_zones/fly_zone_controller.dart';

class FlyZone extends StatefulWidget {
  final FlyZoneController? controller;
  final Widget child;

  const FlyZone({
    Key? key,
    this.controller,
    required this.child,
  }) : super(key: key);

  FlyZone.stacked({
    Key? key,
    this.controller,
    required List<Widget> entries,
    required Widget child,
  })  : child = _buildWithStack(entries, child),
        super(key: key);

  // FlyZone.inOverlay({
  //   Key? key,
  //   this.controller,
  //   required List<Widget> entries,
  //   required Widget child,
  // })  : child = _FlyZoneInOverlay(entries: entries, child: child),
  //       super(key: key);

  static FlyZoneScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FlyZoneScope>()!;
  }

  static Widget _buildWithStack(List<Widget> entries, Widget child) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        ...entries,
      ],
    );
  }

  @override
  State<FlyZone> createState() => _FlyZoneState();
}

class _FlyZoneState extends State<FlyZone> {
  late FlyZoneController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlyZoneController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  RenderBox getRenderBox() => context.findRenderObject() as RenderBox;

  @override
  Widget build(BuildContext context) {
    return FlyZoneScope(
      controller: widget.controller ?? _controller,
      renderBoxGetter: getRenderBox,
      child: widget.child,
    );
  }
}

class FlyZoneScope extends InheritedWidget {
  final FlyZoneController controller;
  final RenderBox Function() _renderBoxGetter;

  RenderBox get renderBox => _renderBoxGetter();

  const FlyZoneScope({
    Key? key,
    required this.controller,
    required RenderBox Function() renderBoxGetter,
    required Widget child,
  })  : _renderBoxGetter = renderBoxGetter,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(FlyZoneScope oldWidget) =>
      controller != oldWidget.controller || _renderBoxGetter != oldWidget._renderBoxGetter;
}

// class _FlyZoneInOverlay extends StatefulWidget {
//   final List<Widget> entries;
//   final Widget child;
//
//   const _FlyZoneInOverlay({
//     Key? key,
//     required this.entries,
//     required this.child,
//   }) : super(key: key);
//
//   @override
//   State<_FlyZoneInOverlay> createState() => _FlyZoneInOverlayState();
// }
//
// class _FlyZoneInOverlayState extends State<_FlyZoneInOverlay> {
//   late final OverlayEntry _entry;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _entry = OverlayEntry(builder: _buildEntries);
//
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       Overlay.of(context)!.insert(_entry);
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }
//
//   @override
//   void dispose() {
//     _entry.remove();
//     super.dispose();
//   }
//
//   @override
//   void didUpdateWidget(_FlyZoneInOverlay oldWidget) {
//     super.didUpdateWidget(oldWidget);
//   }
//
//   Widget _buildEntries(BuildContext context) {
//     return Stack(
//       children: widget.entries,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
