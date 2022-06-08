import 'package:flutter/painting.dart';

class OffsetResolver {
  final Size containerSize;
  final Size childSize;

  const OffsetResolver({
    required this.containerSize,
    required this.childSize,
  });

  bool _isLeft(Offset offset) => containerSize.width / 2 > offset.dx;

  bool _isTop(Offset offset) => containerSize.height / 2 > offset.dy;

  Offset getElasticTarget(Offset origin, EdgeInsets edges) {
    var nextDx = origin.dx;
    var nextDy = origin.dy;

    if (_isLeft(origin)) {
      if (!edges.left.isNaN) nextDx = edges.left;
    } else {
      if (!edges.right.isNaN) {
        nextDx = containerSize.width - (childSize.width + edges.right);
      }
    }
    if (_isTop(origin)) {
      if (!edges.top.isNaN) nextDy = edges.top;
    } else {
      if (!edges.bottom.isNaN) {
        nextDy = containerSize.height - (childSize.height + edges.bottom);
      }
    }
    return Offset(nextDx, nextDy);
  }

  Offset getNaturalTarget(Offset origin, EdgeInsets edges) {
    var nextDx = origin.dx;
    var nextDy = origin.dy;

    if (_isLeft(origin)) {
      if (!edges.left.isNaN) {
        if (origin.dx < edges.left) nextDx = edges.left;
      }
    } else {
      if (!edges.right.isNaN) {
        final marginBottom = containerSize.width - (childSize.width + edges.right);
        if (origin.dx > marginBottom) nextDx = marginBottom;
      }
    }
    if (_isTop(origin)) {
      if (!edges.top.isNaN) {
        if (origin.dy < edges.top) nextDy = edges.top;
      }
    } else {
      if (!edges.bottom.isNaN) {
        final marginBottom = containerSize.height - (childSize.height + edges.bottom);
        if (origin.dy > marginBottom) nextDy = marginBottom;
      }
    }
    return Offset(nextDx, nextDy);
  }

  Offset getRetractedTarget(Offset offset, EdgeInsets edges) {
    var nextDx = offset.dx;
    var nextDy = offset.dy;

    if (_isLeft(offset)) {
      if (!edges.left.isNaN) {
        if (offset.dx > edges.left) nextDx = edges.left;
      }
    } else {
      if (!edges.right.isNaN) {
        final marginBottom = containerSize.width - (childSize.width + edges.right);
        if (offset.dx < marginBottom) nextDx = marginBottom;
      }
    }
    if (_isTop(offset)) {
      if (!edges.top.isNaN) {
        if (offset.dy > edges.top) nextDy = edges.top;
      }
    } else {
      if (!edges.bottom.isNaN) {
        final marginBottom = containerSize.height - (childSize.height + edges.bottom);
        if (offset.dy < marginBottom) nextDy = marginBottom;
      }
    }
    return Offset(nextDx, nextDy);
  }
}
