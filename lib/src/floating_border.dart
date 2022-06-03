// class FloatingBorder {
//   final FloatingEdge? left;
//   final FloatingEdge? top;
//   final FloatingEdge? right;
//   final FloatingEdge? bottom;
//
//   const FloatingBorder({
//     this.left,
//     this.top,
//     this.right,
//     this.bottom,
//   });
//
//   const FloatingBorder.all(FloatingEdge? value)
//       : this(
//           left: value,
//           top: value,
//           right: value,
//           bottom: value,
//         );
// }
//
// enum FloatingEdgeType { relative, fraction }
//
// abstract class FloatingEdge {
//   const factory FloatingEdge.relative(double value) = _RelativeFloatingEdge;
//
//   const factory FloatingEdge.fraction(double value) = _FractionFloatingEdge;
//
//   double resolve(double target, double draggableSize);
// }
//
// class _RelativeFloatingEdge implements FloatingEdge {
//   final double value;
//
//   const _RelativeFloatingEdge(this.value);
//
//   double? resolve(double target, double draggableSize) {
//     if (target > value) return null;
//     return value;
//   }
// }
//
// class _FractionFloatingEdge implements FloatingEdge {
//   final double value;
//
//   const _FractionFloatingEdge(this.value);
//
//   double? resolve(double target, double draggableSize) {
//     final effectiveEdge = draggableSize / value;
//     if (effectiveEdge > target) return null;
//     return effectiveEdge;
//   }
// }

class FloatingEdges {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const FloatingEdges({
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  const FloatingEdges.symmetric({
    double? vertical,
    double? horizontal,
  }) : this(
          top: vertical,
          bottom: vertical,
          left: horizontal,
          right: horizontal,
        );
}
