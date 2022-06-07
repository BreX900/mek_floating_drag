import 'package:flutter/widgets.dart';
import 'package:mek_floating_drag/src/darts/floating_draggable_controller.dart';
import 'package:mek_floating_drag/src/targets/floating_target_controller.dart';

class FloatingZoneController extends ChangeNotifier {
  final _draggableControllers = <FloatingDraggableController>[];
  final _dragTargetControllers = <FloatingDragTargetController>[];

  List<FloatingDraggableController> get draggableControllers =>
      List.unmodifiable(_draggableControllers);
  List<FloatingDragTargetController> get dartTargetControllers =>
      List.unmodifiable(_dragTargetControllers);

  void attachDraggable(FloatingDraggableController controller) {
    _draggableControllers.add(controller);
    controller.isDragging.addListener(_listenDartVisibility);
    notifyListeners();
  }

  void detachDraggable(FloatingDraggableController controller) {
    controller.isDragging.removeListener(_listenDartVisibility);
    _draggableControllers.remove(controller);
    notifyListeners();
  }

  void attachDragTarget(FloatingDragTargetController controller) {
    _dragTargetControllers.add(controller);
    notifyListeners();
  }

  void detachDragTarget(FloatingDragTargetController controller) {
    _dragTargetControllers.remove(controller);
    notifyListeners();
  }

  void _listenDartVisibility() {
    final isDragging = _draggableControllers.any((e) => e.isDragging.value);
    for (final controller in _dragTargetControllers) {
      if (isDragging) {
        controller.show();
      } else {
        controller.hide();
      }
    }
  }
}
