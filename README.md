Enable a widget to be dragged allowing it to be removed if dropped in an area or hidden if time passes or is pressed out.

## Features

TODO: Add list of features

## Getting started

Remember to wrap everything in a FloatingZone

## Usage

Define your draggable widget.

```dart
final draggable = FloatingDraggable(
  controller: _dartController,
  naturalEdgesResolver: (containerSize, childSize) {
    return const EdgeInsets.symmetric(horizontal: double.nan, vertical: 64.0);
  },
  elasticEdgesResolver: (containerSize, childSize) {
    return const EdgeInsets.symmetric(horizontal: 16.0, vertical: double.nan);
  },
  retractEdgesResolver: (containerSize, childSize) {
    return EdgeInsets.symmetric(horizontal: -(0.60 * childSize.width), vertical: double.nan);
  },
  child: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.message),
  ),
);
```

You can define a target for dragging, this target will delete the draggable widget when dropped into it
```dart
const dragTarget = FloatingCircularDragBin();
```

Wrap it all up in a Floating Zone. It is necessary for proper functioning. You can also use `FloatingZone.inOverlay`.
```dart
final result = FloatingZone.inStack(
  entries: [
    const Positioned(
      bottom: 16.0,
      right: 0.0,
      left: 0.0,
      child: dragTargetBin,
    ),
    Positioned(
      bottom: 16.0,
      right: 16.0,
      child: draggable,
    ),
  ],
  child: RestrictedFloatingZone(
    child: scaffold,
  ),
);
```

If you use `RestrictedFloatingZone` you will be able to hide the draggable widget when the user presses in `RestrictedFloatingZone`


## Additional information

TODO: Add additional information

## Developer information

`dart pub global run index_generator`