import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/mek_floating_drag.dart';

class RestrictedFlyZone extends StatefulWidget {
  final List<ScrollController> scrollControllers;
  final Widget child;

  const RestrictedFlyZone({
    Key? key,
    this.scrollControllers = const [],
    required this.child,
  }) : super(key: key);

  @override
  State<RestrictedFlyZone> createState() => _RestrictedFlyZoneState();
}

class _RestrictedFlyZoneState extends State<RestrictedFlyZone> {
  FlyZoneController? _flyZoneController;
  ScrollController? _scrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flyZoneController = FlyZone.of(context);
    final scrollController = PrimaryScrollController.of(context);

    if (_flyZoneController != flyZoneController || _scrollController != scrollController) {
      _flyZoneController = flyZoneController;
      _scrollController = scrollController;

      if (_scrollController != null) _flyZoneController?.attachScroll(_scrollController!);
    }
  }

  @override
  void didUpdateWidget(RestrictedFlyZone oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
