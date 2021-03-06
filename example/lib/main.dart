import 'package:flutter/material.dart';
import 'package:mek_floating_drag/mek_floating_drag.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mek Floating Drag',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final _draggableController = FloatingDraggableController(vsync: this);

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Mek Floating Drag'),
        actions: [
          AnimatedBuilder(
            animation: _draggableController.visibilityAnimation,
            child: IconButton(
              onPressed: () => _draggableController.show(),
              icon: const Icon(Icons.add),
            ),
            builder: (context, child) {
              return Transform.scale(
                scale: 1 - _draggableController.visibilityAnimation.value,
                transformHitTests: false,
                child: child!,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: Colors.primaries.reversed.map((color) {
            return Container(
              height: 100.0,
              color: color,
            );
          }).toList(),
        ),
      ),
    );

    const dragTargetBin = FloatingCircularDragBin();

    final draggable = FloatingDraggable(
      controller: _draggableController,
      naturalEdgesResolver: (containerSize, childSize) {
        return const EdgeInsets.symmetric(horizontal: double.nan, vertical: 16.0);
      },
      elasticEdgesResolver: (containerSize, childSize) {
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: double.nan);
      },
      retractEdgesResolver: (containerSize, childSize) {
        return EdgeInsets.symmetric(horizontal: -(0.60 * childSize.width), vertical: double.nan);
      },
      child: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Tapped!'),
        )),
        child: const Icon(Icons.message),
      ),
    );

    final result = FlyZone.inStack(
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
      child: RestrictedFlyZone(
        child: scaffold,
      ),
    );

    return result;
  }
}
