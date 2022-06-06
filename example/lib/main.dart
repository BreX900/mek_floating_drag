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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  late final _dartController = FloatingDartController(vsync: this);

  @override
  void dispose() {
    _dartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _dartController.show(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RestrictedFlyZone(
        child: SingleChildScrollView(
          child: Column(
            children: Colors.primaries.reversed.map((color) {
              return Container(
                height: 100.0,
                color: color,
              );
            }).toList(),
          ),
        ),
      ),
    );

    const target = FloatingBallTarget();

    final dart = FloatingDart(
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
      ),
    );

    return FlyZone.stacked(
      entries: [
        const Positioned(
          bottom: 16.0,
          right: 0.0,
          left: 0.0,
          child: target,
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: dart,
        ),
      ],
      child: scaffold,
    );
  }
}

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size);
    return Container();
  }
}
