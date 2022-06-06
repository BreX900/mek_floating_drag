import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/darts/floating_dart_controller.dart';
import 'package:mek_floating_drag/src/targets/floating_target_controller.dart';

class FlyZoneController extends ChangeNotifier {
  final _dartControllers = <FloatingDartController>[];
  final _targetControllers = <FloatingTargetController>[];

  List<FloatingDartController> get dartControllers => List.unmodifiable(_dartControllers);
  List<FloatingTargetController> get targetControllers => List.unmodifiable(_targetControllers);

  void attachDart(FloatingDartController controller) {
    _dartControllers.add(controller);
    controller.isDragging.addListener(_listenDartVisibility);
    notifyListeners();
  }

  void detachDart(FloatingDartController controller) {
    controller.isDragging.removeListener(_listenDartVisibility);
    _dartControllers.remove(controller);
    notifyListeners();
  }

  void attachTarget(FloatingTargetController controller) {
    _targetControllers.add(controller);
    notifyListeners();
  }

  void detachTarget(FloatingTargetController controller) {
    _targetControllers.remove(controller);
    notifyListeners();
  }

  void _listenDartVisibility() {
    final isDragging = _dartControllers.any((e) => e.isDragging.value);
    for (final controller in _targetControllers) {
      if (isDragging) {
        controller.show();
      } else {
        controller.hide();
      }
    }
  }
}
