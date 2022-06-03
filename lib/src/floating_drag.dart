import 'package:flutter/widgets.dart';

// FloatingWidget / FloatingStack
class FloatingDrag extends StatefulWidget {
  // final FloatingBorder elasticBorder;
  // final FloatingBorder naturalBorder;
  final WidgetBuilder builder;

  const FloatingDrag({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<FloatingDrag> createState() => _FloatingDragState();
}

class _FloatingDragState extends State<FloatingDrag> with TickerProviderStateMixin {
  final _overlayEntries = <OverlayEntry>[];

  final _birdKey = GlobalKey();
  late final _birdEntry = OverlayEntry(
    builder: _build,
  );
  Offset _birdOffset = Offset(20.0, 20.0);
  late AnimationController _birdAdjustController;
  Animation<Offset>? _birdAdjustAnimation;

  @override
  void initState() {
    super.initState();
    _birdAdjustController = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    _birdAdjustController.addListener(() {
      if (_birdAdjustAnimation == null) return;
      _birdOffset = _birdAdjustAnimation!.value;
      _birdEntry.markNeedsBuild();
    });
    _overlayEntries.add(_birdEntry);
  }

  Widget _build(BuildContext context) {
    final padding = EdgeInsets.symmetric(vertical: -1.0, horizontal: 16.0);
    final margin = EdgeInsets.symmetric(vertical: 100.0, horizontal: -1);
    RelativeRect;
    Rect;
    // Transform.translate
    return Stack(
      children: [
        Positioned(
          top: _birdOffset.dy,
          left: _birdOffset.dx,
          child: GestureDetector(
            onPanStart: (details) {
              _birdAdjustAnimation = null;
              _birdAdjustController.stop();
            },
            onPanUpdate: (details) {
              _birdOffset = _birdOffset + details.delta;
              _birdEntry.markNeedsBuild();
            },
            onPanEnd: (details) {
              final externalBox = context.findRenderObject() as RenderBox;
              final childBox = _birdKey.currentContext!.findRenderObject() as RenderBox;
              final currentOffset = _birdOffset;

              final isLeft = externalBox.size.width / 2 > currentOffset.dx;
              final isTop = externalBox.size.height / 2 > currentOffset.dy;

              var nextDx = currentOffset.dy;
              var nextDy = currentOffset.dy;

              // Paddings

              if (isLeft) {
                if (padding.left >= 0) nextDx = padding.left;
              } else {
                final paddingRight = externalBox.size.width - (childBox.size.width + padding.right);
                if (padding.right >= 0) nextDx = paddingRight;
              }
              if (isTop) {
                if (padding.top >= 0) nextDy = padding.top;
              } else {
                final paddingBottom =
                    externalBox.size.height - (childBox.size.height + padding.bottom);
                if (padding.bottom >= 0) nextDy = paddingBottom;
              }

              // Margins

              if (isLeft) {
                if (currentOffset.dx < margin.left) nextDy = margin.left;
              } else {
                final marginBottom = externalBox.size.width - (childBox.size.width + margin.right);
                if (currentOffset.dx > marginBottom) nextDy = marginBottom;
              }
              if (isTop) {
                if (currentOffset.dy < margin.top) nextDy = margin.top;
              } else {
                final marginBottom = externalBox.size.height - (childBox.size.height + margin.top);
                if (currentOffset.dy > marginBottom) nextDy = marginBottom;
              }

              _birdAdjustController.value = 0.0;
              _birdAdjustAnimation = _birdAdjustController.drive(Tween(
                begin: currentOffset,
                end: Offset(nextDx, nextDy),
              ));
              _birdAdjustController.forward();
            },
            child: FittedBox(
              fit: BoxFit.none,
              child: KeyedSubtree(
                key: _birdKey,
                child: widget.builder(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: _overlayEntries,
    );
  }
}
