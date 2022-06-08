Enable a widget to be dragged allowing it to be removed if dropped in an area or hidden if time passes or is pressed out.

[**TRY WEB APP EXAMPLE**](https://brex900.github.io/mek_floating_drag/#/)

## Features

- [x] You can drag it anywhere you want
- [x] The button is attracted to the edges of the container, it bounces!
- [x] The button, if released outside the natural edges, is attracted inside
- [x] The Button hides when some time passes
- [x] The button hides if you don't play with him, if you hit someone else
- [x] You can delete the button by dragging it over an area (Bin)
- [x] When the button is released inside the bin it shrinks and aligns with the center of the bin
- [ ] When the button approaches the bin it is attracted to it

## Getting started

Remember to wrap everything in a ´FloatingZone´

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

- Release: `flutter pub publish`
- Generate barrel file: `dart pub global run index_generator`